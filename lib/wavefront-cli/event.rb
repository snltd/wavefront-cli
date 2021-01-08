# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'etc'
require 'wavefront-sdk/support/mixins'
require_relative 'base'
require_relative 'command_mixins/tag'

module WavefrontCli
  #
  # CLI coverage for the v2 'event' API.
  #
  class Event < Base
    attr_reader :state

    include Wavefront::Mixins
    include WavefrontCli::Mixin::Tag

    def post_initialize(options)
      @state = WavefrontCli::LocalEventStore.new(options)
    end

    def do_list
      wf.list(*list_args)
    end

    def do_create(opts = nil)
      opts ||= options
      opts[:start] = Time.now unless opts[:start]
      t_start = parse_time(opts[:start], true)
      body = create_body(opts, t_start)
      resp = wf.create(body)
      return if opts[:noop]

      state.create!(resp.response[:id])
      resp
    end

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
      puts "Command exited #{exit_code}."
      exit exit_code
    end

    # The user doesn't have to give us an event ID.  If no event
    # name is given, we'll pop the last event off the stack. If an
    # event name is given and it doesn't look like a full WF event
    # name, we'll look for something on the stack.  If it does look
    # like a real event, we'll make an API call straight away.
    #
    def do_close(id = nil)
      id ||= options[:'<id>']
      ev = local_event(id)
      ev_file = event_file(id)

      abort "No locally stored event matches '#{id}'." unless ev

      res = wf.close(ev)
      ev_file.unlink if ev_file&.exist? && res.status.code == 200
      res
    end

    def list_args
      [window_start,
       window_end,
       options[:limit] || 100,
       options[:cursor] || nil]
    end

    def window_start
      parse_time((options[:start] || Time.now - 600), true)
    end

    def window_end
      parse_time((options[:end] || Time.now), true)
    end

    # return [Hash] body for #create() method
    #
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def create_body(opts, t_start)
      { name: opts[:'<event>'],
        startTime: t_start,
        annotations: annotations(opts) }.tap do |r|
          r[:hosts] = opts[:host] if opts[:host]
          r[:tags] = opts[:evtag] if opts[:evtag]

          if opts[:instant]
            r[:endTime] = t_start + 1
          elsif opts[:end]
            r[:endTime] = parse_time(opts[:end], true)
          end
        end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def annotations(opts)
      {}.tap do |r|
        r[:details] = opts[:desc] if opts[:desc]
        r[:severity] = opts[:severity] if opts[:severity]
        r[:type] = opts[:type] if opts[:type]
      end
    end
  end
end

require_relative 'constants'

module WavefrontCli
  #
  # Encapsulation of everything needed to manage the locally stored state of
  # events opened by the CLI. This is our own addition, entirely separate from
  # Wavefront's API.
  #
  # When the user creates an open-ended event (i.e. one that does not have and
  # end time, and is not instantaneous) a state file is created in a local
  # directory. (*)
  #
  # That directory isw
  #
  # (*) The user may specifically request that no state file be created with the
  # --nostate flag.
  #
  #
  class LocalEventStore
    include WavefrontCli::Constants

    attr_reader :dir, :options

    # @param state_dir [Pathname] override the default dir for testing
    #
    def initialize(options, state_dir = nil)
      @options = options
      @dir = event_state_dir(state_dir) + (Etc.getlogin || 'notty')
      create_dir(dir)
    end

    def state_file_needed?
      !(options[:nostate] || options[:end] || options[:instant])
    end

    def event_file(id)
      id =~ /^\d{13}:.+/ ? dir + id : nil
    end

    # We can override the temp directory with the WF_EVENT_STATE_DIR env var.
    # This is primarily for testing.
    #
    def event_state_dir(state_dir)
      return EVENT_STATE_DIR if state_dir.nil?

      Pathname.new(state_dir)
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
      events = dir.children
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
        while l = out.gets do warn l end
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
    def create!(id)
      return unless state_file_needed?

      fname = dir + id
      File.open(fname, 'w') { |fh| fh.puts(event_file_data) }
      puts "Event state recorded at #{fname}."
    rescue StandardError => e
      pp e
      puts 'NOTICE: event was created but state file was not.'
    end

    # Record event data in the state file. We don't currently use it, but it
    # might be useful to someone someday.
    #
    # @return [String]
    #
    def event_file_data
      { hosts: options[:host],
        description: options[:desc],
        severity: options[:severity],
        tags: options[:evtag] }.to_json
    end

    def create_dir(state_dir)
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
