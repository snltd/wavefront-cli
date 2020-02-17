# frozen_string_literal: true

require_relative 'base'
require_relative 'command_mixins/tag'

module WavefrontCli
  #
  # CLI coverage for the v2 'maintenancewindow' API.
  #
  class MonitoredCluster < WavefrontCli::Base
    include WavefrontCli::Mixin::Tag

    def do_create
      body = { version: options[:version],
               name: options[:'<name>'],
               platform: options[:'<platform>'],
               id: options[:'<id>'],
               additionalTags: {},
               tags: [] }
      wf.create(body)
    end

    def do_merge
      wf.merge(options[:'<id_to>'], options[:'<id_from>'])
    end

    def validator_exception
      Wavefront::Exception::InvalidMonitoredClusterId
    end

    def descriptive_name
      'monitored cluster'
    end

    def extra_validation
      return unless options[:merge]

      validate_merge_id(options[:'<id_to>'])
      validate_merge_id(options[:'<id_from>'])
    end

    private

    def validate_merge_id(id)
      wf_monitoredcluster_id?(id)
    rescue Wavefront::Exception::InvalidMonitoredClusterId
      abort "'#{id}' is not a valid cluster ID."
    end
  end
end
