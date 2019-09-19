# frozen_string_literal: true

require_relative 'base'
require_relative 'command_mixins/tag'

module WavefrontCli
  #
  # CLI coverage for the v2 'derivedmetric' API.
  #
  class DerivedMetric < WavefrontCli::Base
    include WavefrontCli::Mixin::Tag

    def validator_exception
      Wavefront::Exception::InvalidDerivedMetricId
    end

    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_delete
      smart_delete('derived metric')
    end

    def do_history
      wf.history(options[:'<id>'])
    end

    def do_create
      wf.create(create_body)
    end

    # rubocop:disable Metrics/AbcSize
    def create_body
      { query: options[:'<query>'],
        name: options[:'<name>'],
        minutes: options[:range].to_i,
        includeObsoleteMetrics: options[:obsolete],
        processRateMinutes: options[:interval].to_i }.tap do |b|
          b[:additionalInformation] = options[:desc] if options[:desc]
          b[:tags] = options[:ctag] if valid_tags?
        end
    end
    # rubocop:enable Metrics/AbcSize

    def valid_tags?
      !options[:ctag].empty? && validate_tags(options[:ctag])
    end
  end
end
