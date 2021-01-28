# frozen_string_literal: true

require 'etc'
require 'fileutils'
require 'open3'
require 'json'
require_relative 'constants'
require_relative 'exception'

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
  # That directory is defined by the EVENT_STATE_DIR constant, but may be
  # overriden with an option in the constructor. The tests do this.
  #
  # (*) The user may specifically request that no state file be created with
  # the --nostate flag.
  #
  class EventStore
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
      /^\d{13}:.+/.match?(id) ? dir + id : nil
    end

    # We can override the temp directory with the WF_EVENT_STATE_DIR env var.
    # This is primarily for testing, though someone may find a valid use for
    # it.
    #
    def event_state_dir(state_dir = nil)
      if ENV['WF_EVENT_STATE_DIR']
        Pathname.new(ENV['WF_EVENT_STATE_DIR'])
      elsif state_dir.nil?
        EVENT_STATE_DIR
      else
        Pathname.new(state_dir)
      end
    end

    # @param id [String,Nil] if this is falsey, returns the event on the top
    #   of the state stack, removing its state file. If it's an exact event
    #   ID, simply pass that ID back, NOT removing the state file. This is
    #   okay: the state file is cleaned up by WavefrontCli::Event when an
    #   event is closed.  If it's a name but not an ID, return the ID of the
    #   most recent event with the given name.
    # @return [String] the name of the most recent suitable event from the
    #   local stack directory.
    #
    def event(id)
      if !id
        pop_event!
      elsif /^\d{13}:.+:\d+/.match?(id)
        id
      else
        pop_event!(id)
      end
    end

    # List events on the local stack
    #
    def list
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

    # Write a state file. We put the hosts bound to the event into the file.
    # These aren't currently used by anything in the CLI, but they might be
    # useful to someone, somewhere, someday.
    # @return [Nil]
    #
    def create!(id)
      return unless state_file_needed?

      fname = dir + id
      File.open(fname, 'w') { |fh| fh.puts(event_file_data) }
      puts "Event state recorded at #{fname}."
    rescue StandardError
      puts 'NOTICE: event was created but state file was not.'
    end

    # Record event data in the state file. We don't currently use it, but it
    # might be useful to someone someday.
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
      raise unless state_dir.exist? &&
                   state_dir.directory? &&
                   state_dir.writable?
    rescue StandardError
      raise(WavefrontCli::Exception::SystemError,
            "Cannot create writable system directory at '#{state_dir}'.")
    end

    # Get the last event this script created. If you supply a name, you get
    # the last event with that name. If not, you get the last event. Note the
    # '!': this method (potentially) has side effects.
    # @param name [String] name of event. This is the middle part of the real
    #   event name: the only part supplied by the user.
    # @return [Array[timestamp, event_name]]
    #
    def pop_event!(name = nil)
      return false unless dir.exist?

      list = local_events_with_name(name)
      return false if list.empty?

      ev_file = list.max
      File.unlink(ev_file)
      ev_file.basename.to_s
    end

    # Event names are of the form `1609860826095:name:0`
    # @param name [String] the user-specified (middle) portion of an event ID
    # @return [Array[String]] list of matching events
    #
    def local_events_with_name(name = nil)
      return list unless name

      list.select { |f| f.basename.to_s.split(':')[1] == name }
    end
  end
end
