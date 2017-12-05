require 'fileutils'
require 'wavefront-sdk/mixins'
require_relative './base'
require 'open3'

EVENT_STATE_DIR = Pathname.new('/var/tmp/wavefront')
module WavefrontCli
  #
  # CLI coverage for the v2 'event' API.
  #
  class Event < WavefrontCli::Base
    attr_reader :state_dir
    include Wavefront::Mixins

    def post_initialize(_options)
      @state_dir = EVENT_STATE_DIR + (Etc.getlogin || 'notty')
      create_state_dir
    end

    def do_list
      wf.list(options[:start]  || Time.now - 600,
              options[:end]    || Time.now,
              options[:limit]  || 100,
              options[:cursor] || nil)
    end

    def do_update
      k, v = options[:'<key=value>'].split('=')
      wf.update(options[:'<id>'], k => v)
    end

    # You can override the options generated by docopt. This is how
    # #wrap() works.
    #
    # rubocop:disable Metrics/CyclomaticComplexity
    def do_create(opts = nil)
      opts ||= options

      opts[:start] = Time.now unless opts[:start]

      t_start = parse_time(opts[:start], true)

      body = create_body(opts, t_start)

      resp = wf.create(body)

      unless opts[:nostate] || opts[:end] || opts[:instant]
        create_state_file(resp.response[:id], opts[:host])
      end

      resp
    end

    # The user doesn't have to give us an event ID.  If no event
    # name is given, we'll pop the last event off the stack. If an
    # event name is given and it doesn't look like a full WF event
    # name, we'll look for something on the stack.  If it does look
    # like a real event, we'll make and API call straight away.
    #
    def do_close(id = nil)
      id ||= options[:'<id>']
      ev_file = id =~ /^\d{13}:.+/ ? state_dir + id : nil
      ev = local_event(id)

      abort "No locally stored event matches '#{id}'." unless ev

      res = wf.close(ev)
      ev_file.unlink if ev_file && ev_file.exist? && res.status.code == 200
      res
    end

    def do_show
      events = local_event_list

      if events.size.zero?
        puts 'No open events.'
      else
        events.sort.reverse.each { |e| puts e.basename }
      end

      exit
    end

    def do_wrap
      create_opts = options
      create_opts[:desc] ||= create_opts[:command]
      event_id = do_create(create_opts).response.id
      exit_code = run_wrapped_cmd(options[:command])
      do_close(event_id)
      puts "Command exited #{exit_code}"
      exit exit_code
    end

    private

    # return [Hash] body for #create() method
    #
    def create_body(opts, t_start)
      body = { name:        opts[:'<event>'],
               startTime:   t_start,
               annotations: {} }

      body[:annotations][:details] = opts[:desc] if opts[:desc]
      body[:annotations][:severity] = opts[:severity] if opts[:severity]
      body[:annotations][:type] = opts[:type] if opts[:type]
      body[:hosts] = opts[:host] if opts[:host]
      body[:tags] = opts[:evtag] if opts[:evtag]

      if opts[:instant]
        body[:endTime] = t_start + 1
      elsif opts[:end]
        body[:endTime] = parse_time(opts[:end], true)
      end

      body
    end

    # @return a local event from the stack directory
    #
    def local_event(id)
      if !id
        pop_event
      elsif id =~ /^\d{13}:.+/
        id
      else
        pop_event(id)
      end
    end

    def local_event_list
      state_dir.children
    rescue Errno::ENOENT
      raise 'There is no event state directory on this host.'
    end

    # Run a command, stream stderr and stdout to the screen (they
    # get combined -- could be an issue for someone somewhere) and
    # return the command's exit code
    #
    # rubocop:disable Lint/AssignmentInCondition
    #
    def run_wrapped_cmd(cmd)
      separator = '-' * (TW - 4)

      puts "Command output follows, on STDERR:\n#{separator}"
      ret = nil

      Open3.popen2e(cmd) do |_in, out, thr|
        while l = out.gets do STDERR.puts(l) end
        ret = thr.value.exitstatus
      end

      puts separator
      ret
    end

    # Write a state file. We put the hosts bound to the event into the
    # file. These aren't currently used by anything in the CLI, but they
    # might be useful to someone, somewhere, someday.
    #
    def create_state_file(id, hosts = [])
      fname = state_dir + id

      begin
        File.open(fname, 'w') { hosts.to_s }
      rescue StandardError
        raise 'Event was created but state file was not.'
      end

      puts "Event state recorded at #{fname}."
    end

    def create_state_dir
      FileUtils.mkdir_p(state_dir)
      return true if state_dir.exist? && state_dir.directory? &&
                     state_dir.writable?
      raise 'Cannot create state directory.'
    end

    def validate_input
      validate_id if options[:'<id>'] && !options[:close]
      validate_tags if options[:'<tag>']
      validate_tags(:evtag) if options[:evtag]
      send(:extra_validation) if respond_to?(:extra_validation)
    end

    # Get the last event this script created. If you supply a name, you
    # get the last event with that name. If not, you get the last event.
    # Chances are you'll only ever have one in-play at once.
    #
    # @param name [String] name of event
    # @eturn an array of [timestamp, event_name]
    #
    def pop_event(name = nil)
      return false unless state_dir.exist?

      list = local_events_with_name(name)
      return false if list.empty?

      ev_file = list.sort.last
      File.unlink(ev_file)
      ev_file.basename.to_s
    end

    def local_events_with_name(name = nil)
      list = local_event_list

      return list unless name

      list.select { |f| f.basename.to_s.split(':').last == name }
    end
  end
end
