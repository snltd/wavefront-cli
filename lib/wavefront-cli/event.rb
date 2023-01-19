# frozen_string_literal: true

require 'wavefront-sdk/support/mixins'
require_relative 'base'
require_relative 'event_store'
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
      @state = WavefrontCli::EventStore.new(options)
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
      events = state.list

      if events.empty?
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
      exit_code = state.run_wrapped_cmd(options[:command])
      do_close(event_id)
      puts "Command exited #{exit_code}."
      exit exit_code
    end

    # The user doesn't have to give us an event ID. If no event name is given,
    # we'll pop the last event off the stack. If an event name is given and it
    # doesn't look like a full WF event name, we'll look for something on the
    # stack. If it does look like a real event, we'll make an API call
    # straight away.
    #
    def do_close(id = nil)
      id ||= options[:'<id>']
      ev = state.event(id)
      ev_file = state.event_file(id)

      abort "No locally stored event matches '#{id}'." unless ev

      res = wf.close(ev)
      ev_file.unlink if ev_file&.exist? && res.status.code == 200
      res
    end

    # We have to override the normal validation methods because an event can
    # be referred to by only a part of its name. This happens when the user
    # refers to events on the local stack.
    #
    def validate_input
      validate_id if options[:'<id>'] && !options[:close]
      validate_tags if options[:'<tag>']
      validate_tags(:evtag) if options[:evtag]
      send(:extra_validation) if respond_to?(:extra_validation)
    end

    def list_args
      [window_start,
       window_end,
       options[:limit] || 100,
       options[:cursor] || nil]
    end

    def window_start
      parse_time((options[:start] || (Time.now - 600)), true)
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
