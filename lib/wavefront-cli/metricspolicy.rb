# frozen_string_literal: true

require 'wavefront-sdk/support/mixins'
require_relative 'base'
require_relative 'helpers/load_file'

module WavefrontCli
  #
  # CLI coverage for the metricspolicy part of the v2 'usage' API.
  #
  class MetricsPolicy < WavefrontCli::Base
    def do_describe
      wf.describe(options[:version])
    end

    def do_history
      wf.history(options[:offset] || 0, options[:limit] || 100)
    end

    def do_revert
      wf.revert(options[:'<version>'])
    end

    def do_update
      raw = WavefrontCli::Helper::LoadFile.new(options[:'<file>']).load
      rules = process_update(raw)
      wf.update(policyRules: rules)
    end

    # It looks like the API expects arrays of ID strings for accounts, groups,
    # and roles, but when you export one, those fields are objects with name
    # and ID.
    #
    def process_update(raw)
      raw[:policyRules].tap do |rule|
        rule[:accounts] = rule[:accounts].map { |r| r[:id] }
        rule[:userGroups] = rule[:userGroups].map { |r| r[:id] }
        rule[:roles] = rule[:roles].map { |r| r[:id] }
      end
    end
  end
end
