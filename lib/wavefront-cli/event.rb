require 'wavefront-sdk/mixins'
require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'event' API.
  #
  class Event < WavefrontCli::Base
    attr_reader :state_dir
    include Wavefront::Mixins

    def post_initialize(options)
      begin
        @state_dir = Pathname.new(EVENT_STATE_DIR) + Etc.getlogin
      rescue
        @state_dir = Pathname.new(EVENT_STATE_DIR) + 'notty'
      end

      create_state_dir
    end

    def do_list
      @verbose_response = true
      @col2 = 'runningState'
      options[:start] = Time.now - 600 unless options[:start]
      options[:end] = Time.now unless options[:end]

      wf.list(options[:start], options[:end], options[:limit] || 100,
              options[:offset] || nil)
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'])
    end

    def do_update
      k, v = options[:'<key=value>'].split('=')
      wf.update(options[:'<id>'], { k => v })
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
      body[:host] = options[:host] if options[:host]

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

    def do_close
      wf.close(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_tags
      @verbose_response = true
      wf.tags(options[:'<id>'])
    end

    def do_tag_add
      wf.tag_add(options[:'<id>'], options[:'<tag>'].first)
    end

    def do_tag_delete
      wf.tag_delete(options[:'<id>'], options[:'<tag>'].first)
    end

    def do_tag_set
      wf.tag_set(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_clear
      wf.tag_set(options[:'<id>'], [])
    end

    def humanize_tags_output(data)
      data.sort.each { |t| puts t }
    end

    def do_show
      @no_response = true

      begin
        events = state_dir.children
      rescue Errno::ENOENT
        raise 'There is no event state directory on this host.'
      end

      if events.size.zero?
        puts 'No open events.'
      else
        events.each { |e| puts e.basename }
      end
    end

    private

    # Write a state file. We put the hosts bound to the event into the
    # file. These aren't currently used by anything in the CLI, but they
    # might be useful to someone, somewhere, someday.
    #
    def create_state_file(id, hosts = [])
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
      unless state_dir.exist? && state_dir.directory? && state_dir.writable?
        raise 'Cannot create state directory.'
      end
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
      list.select! { |f| f.basename.to_s.split('::').last == name } if name
      return false if list.length == 0
      list.sort.last.basename.to_s.split('::')
    end
    end
  end

  =begin
  require 'json'
  require 'time'
  require 'fileutils'
  require 'etc'
  require 'socket'
  require 'wavefront-sdk/event'
  require_relative './base'
  #
  # Open and close events via the Wavefront API.
  #
  # It is straightforward to create instantaneous events, or events
  # with a defined start and end time: one API call is all you need,
  # and the job is done.  But often when you open an event you don't
  # know when you want to close it, and closing requires very specific
  # information which the API returns when the event is opened.
  #
  # To help the user close these events, we use a files in a local
  # directory to record the state of any events we open.  The
  # directory behaves like an event "stack": a freshly created event
  # is "pushed" onto the "stack", and telling the script to close an
  # event with no further specification "pops" the last even off the
  # "stack", and closes it.  We give each user their own state
  # directory, under /var/tmp/wavefront/events.
  #
  # We also provide a way of seeing which events the CLI thinks are
  # open. This is in no way a substitute for using an events() query
  # in a timeseries API call.
  #
  class WavefrontCli::Event < WavefrontCli::Base
    attr_accessor :state_dir, :hosts, :hostname, :t_start, :t_end,
                  :wf_event

      @hostname = Socket.gethostname
      @hosts = prep_hosts(options[:host])
      @t_start = prep_time(:start)
      @t_end = prep_time(:end)
      @noop = options[:noop]

      @wf_event = Wavefront::Event.new(
        options[:token], options[:endpoint], options[:debug],
        { verbose: options[:verbose], noop: options[:noop]})

      if options[:create]
        create_event_handler
      elsif options[:close]
        close_event_handler
      elsif options[:show]
        show_open_events
      elsif options[:delete]
        delete_event
      else
        fail 'undefined event error.'
      end
    end

    def delete_event
      unless options[:'<timestamp>'] && options[:'<event>']
        fail 'To delete an event you must supply its start time and name.'
      end

      begin
        wf_event.delete(startTime: options[:'<timestamp>'],
                        name: options[:'<event>']
                       )
      rescue RestClient::Unauthorized
        raise 'Cannot connect to Wavefront API.'
      rescue RestClient::ResourceNotFound
        raise 'Cannot find that event.'
      rescue => e
        puts e
        raise 'Cannot delete event.'
      end

      puts 'Deleted event.' unless noop
    end

    def prep_time(t)
      #
      # Wavefront would like times in epoch milliseconds, so whatever
      # we have got, turn them into that.
      #
      options[t] ? time_to_ms(parse_time(options[t])) : false
    end

    def prep_hosts(hosts = false)
      #
      # We allow the user to associate an event with multiple hosts,
      # or to pass in some identifer other than the hostname. If they
      # have not done this, hostname is used
      #
      hosts = hostname unless hosts
      hosts.split(',')
    end

    def close_event_handler
      #
      # The user can specify all, some, or none of the information
      # needed to close an event. If we have all of it, we can jump
      # straight to the API call. Otherwise, we have to go and look
      # for a state fuile
      #
      if options[:'<timestamp>'] && options[:'<event>']
        close_event(options[:'<event>'], options[:'<timestamp>'])
      else
        ev_file = pop_event(options[:'<event>'])

        if ev_file
          close_event(ev_file[1], ev_file[0])
        else
          fail "No event '#{options[:'<event>']}' to close."
        end
      end
    end

    def close_event(ev_name, ts)
      puts "Closing event '#{ev_name}'. [#{Time.at(ts.to_i / 1000)}]"

      begin
        wf_event.close(
          s: ts,
          n: ev_name
        )
      rescue RestClient::Unauthorized
        raise 'Not authorized to connect to Wavefront.'
      rescue => e
        puts e
        raise
      end

      # Remove the state file, if there was one
      #
      state_file = state_filename(ev_name, ts)

      return unless state_file.exist?

      puts "Removing state file #{state_file}."
      File.unlink state_file
    end

    def validate_opts
      #
      # the 'show' sub-command does not make an API call
      #
    return true if options[:show]
    abort 'Please supply an API token.' unless options[:token]
    abort 'Please supply an API endpoint.' unless options[:endpoint]
  end
end
=end
