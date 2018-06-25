require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'derivedmetric' API.
  #
  class DerivedMetric < WavefrontCli::Base
    def validator_exception
      Wavefront::Exception::InvalidDerivedMetricId
    end

    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_delete
      word = if wf.describe(options[:'<id>']).status.code == 200
               'Soft'
             else
               'Permanently'
             end

      puts format('%s deleting derived metric definition %s', word,
                  options[:'<id>'])

      wf.delete(options[:'<id>'])
    end

    def do_history
      wf.history(options[:'<id>'])
    end

    def do_create
      wf.create(build_body)
    end

    def build_body
      ret = { query:              options[:'<query>'],
              name:               options[:'<name>'],
              minutes:            options[:range].to_i,
              processRateMinutes: options[:interval].to_i }

      ret[:additionalInformation] = options[:desc] if options[:desc]
      ret
    end
  end
end
