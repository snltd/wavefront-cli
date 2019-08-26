require 'fileutils'
require 'open3'
require 'wavefront-sdk/support/mixins'
require_relative 'base'
require_relative 'command_mixins/tag'

module WavefrontCli
  #
  # CLI coverage for the v2 'event' API.
  #
  class Event < Base
    attr_accessor :state_dir

    include Wavefront::Mixins
    include WavefrontCli::Mixin::Tag

    def post_initialize(_options)
      @state_dir = event_state_dir + (Etc.getlogin || 'notty')
      create_state_dir
    end

    def do_list
      wf.list(options[:start]  || Time.now - 600,
              options[:end]    || Time.now,
              options[:limit]  || 100,
              options[:cursor] || nil)
    end

    # rubocop:disable Metrics/AbcSize
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
    # rubocop:enable Metrics/AbcSize

    # The user doesn't have to give us an event ID.  If no event
    # name is given, we'll pop the last event off the stack. If an
    # event name is given and it doesn't look like a full WF event
    # name, we'll look for something on the stack.  If it does look
    # like a real event, we'll make and API call straight away.
    #
    # rubocop:disable Metrics/AbcSize
    def do_close(id = nil)
      id ||= options[:'<id>']
      ev_file = id =~ /^\d{13}:.+/ ? state_dir + id : nil
      ev = local_event(id)

      abort "No locally stored event matches '#{id}'." unless ev

      res = wf.close(ev)
      ev_file.unlink if ev_file&.exist? && res.status.code == 200
      res
    end
    # rubocop:enable Metrics/AbcSize

    def do_show
      events = local_event_list

      if events.size.zero?
        puts 'No open events.'
      else
        events.sort.reverse_each { |e| puts e.basename }
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

    def event_state_dir
      options[:event_state_dir] || EVENT_STATE_DIR
    end

    # return [Hash] body for #create() method
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
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
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize

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
      events = state_dir.children
      abort 'No locally recorded events.' if events.empty?

      events
    rescue Errno::ENOENT
      raise(WavefrontCli::Exception::SystemError,
            'There is no event state directory on this host.')
    end

    # Run a command, stream stderr and stdout to the screen (they
    # get combined -- could be an issue for someone somewhere) and
    # return the command's exit code
    #
    def run_wrapped_cmd(cmd)
      separator = '-' * (TW - 4)

      puts "Command output follows, on STDERR:\n#{separator}"
      ret = nil

      Open3.popen2e(cmd) do |_in, out, thr|
        # rubocop:disable Lint/AssignmentInCondition
        while l = out.gets do STDERR.puts(l) end
        # rubocop:enable Lint/AssignmentInCondition
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
      p state_dir
      fname = state_dir + id
      puts fname
      File.open(fname, 'w') { hosts.to_s }
      puts "Event state recorded at #{fname}."
    rescue StandardError => e
      p e
      puts 'NOTICE: event was created but state file was not.'
    end

    def create_state_dir
      FileUtils.mkdir_p(state_dir)
      raise unless state_dir.exist? && state_dir.directory? &&
                   state_dir.writable?
    rescue StandardError
      raise(WavefrontCli::Exception::SystemError,
            "Cannot create writable system directory at '#{state_dir}'.")
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

      ev_file = list.max
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
