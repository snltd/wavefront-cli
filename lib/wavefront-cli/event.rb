require 'fileutils'
require 'wavefront-sdk/mixins'
require_relative './base'

EVENT_STATE_DIR = Pathname.new('/var/tmp/wavefront')

module WavefrontCli
  #
  # CLI coverage for the v2 'event' API.
  #
  class Event < WavefrontCli::Base
    attr_reader :state_dir
    include Wavefront::Mixins

    def post_initialize(_options)
      begin
        @state_dir = EVENT_STATE_DIR + Etc.getlogin
      rescue
        @state_dir = EVENT_STATE_DIR + 'notty'
      end

      create_state_dir
    end

    def do_list
      options[:start] = Time.now - 600 unless options[:start]
      options[:end] = Time.now unless options[:end]
      wf.list(options[:start], options[:end], options[:limit] || 100,
              options[:cursor] || nil)
    end

    def do_update
      k, v = options[:'<key=value>'].split('=')
      wf.update(options[:'<id>'], k => v)
    end

    def do_create
      options[:start] = Time.now unless options[:start]

      t_start = parse_time(options[:start], true)
      id = [t_start, options[:'<event>']].join(':')

      body = { name:        options[:'<event>'],
               startTime:   t_start,
               id:          id,
               annotations: {} }

      body[:annotations][:details] = options[:desc] if options[:desc]
      body[:annotations][:severity] = options[:severity] if options[:severity]
      body[:annotations][:type] = options[:type] if options[:type]
      body[:hosts] = options[:host] if options[:host]

      if options[:instant]
        body[:endTime] = t_start + 1
      elsif options[:end]
        body[:endTime] = parse_time(options[:end], true)
      end

      resp = wf.create(body)

      unless options[:nostate] || options[:end] || options[:instant]
        create_state_file(id, options[:host])
      end

      resp
    end

    # The user doesn't have to give us an event ID.  If no event
    # name is given, we'll pop the last event off the stack. If an
    # event name is given and it doesn't look like a full WF event
    # name, we'll look for something on the stack.  If it does look
    # like a real event, we'll make and API call straight away.
    #
    def do_close
      ev_file = nil

      ev = if options[:'<id>'] == false
             pop_event
           elsif options[:'<id>'] =~ /^\d{13}:.+/
             ev_file = state_dir + options[:'<id>']
             options[:'<id>']
           else
             pop_event(options[:'<id>'])
           end

      abort "No locally stored event matches '#{options[:'<id>']}'." unless ev

      res = wf.close(ev)
      ev_file.unlink if ev_file && ev_file.exist? && res.status.code == 200
      res
    end

    def do_show
      begin
        events = state_dir.children
      rescue Errno::ENOENT
        raise 'There is no event state directory on this host.'
      end

      if events.size.zero?
        puts 'No open events.'
      else
        events.sort.reverse.each { |e| puts e.basename }
      end

      exit
    end

    private

    # Write a state file. We put the hosts bound to the event into the
    # file. These aren't currently used by anything in the CLI, but they
    # might be useful to someone, somewhere, someday.
    #
    def create_state_file(id, hosts = [])
      puts "statfile fir #{id}"
      fname = state_dir + id

      begin
        File.open(fname, 'w') { hosts.to_s }
      rescue
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
      send(:extra_validation) if respond_to?(:extra_validation)
    end

    # Get the last event this script created. If you supply a name, you
    # get the last event with that name. If not, you get the last event.
    # Chances are you'll only ever have one in-play at once.
    #
    # @param name [String] name of event
    # Returns an array of [timestamp, event_name]
    #
    def pop_event(name = false)
      return false unless state_dir.exist?

      list = state_dir.children

      list.select! { |f| f.basename.to_s.split(':').last == name } if name

      return false if list.empty?

      ev_file = list.sort.last
      File.unlink(ev_file)
      ev_file.basename.to_s
    end
  end
end
