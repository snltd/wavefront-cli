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

    # rubocop:disable Metrics/AbcSize
    def do_delete
      cannot_noop!

      word = if wf.describe(options[:'<id>']).status.code == 200
               'Soft'
             else
               'Permanently'
             end

      puts format('%s deleting derived metric definition %s', word,
                  options[:'<id>'])

      wf.delete(options[:'<id>'])
    end
    # rubocop:enable Metrics/AbcSize

    def do_history
      wf.history(options[:'<id>'])
    end

    def do_create
      wf.create(build_body)
    end

    # rubocop:disable Metrics/AbcSize
    def build_body
      ret = { query:                  options[:'<query>'],
              name:                   options[:'<name>'],
              minutes:                options[:range].to_i,
              includeObsoleteMetrics: options[:obsolete],
              processRateMinutes:     options[:interval].to_i }

      ret[:additionalInformation] = options[:desc] if options[:desc]
      ret[:tags] = options[:ctag] if valid_tags?
      ret
    end
    # rubocop:enable Metrics/AbcSize

    def valid_tags?
      !options[:ctag].empty? && validate_tags(options[:ctag])
    end
  end
end
