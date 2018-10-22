require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'externallink' API.
  #
  class ExternalLink < WavefrontCli::Base
    def validator_method
      :wf_link_id?
    end

    def validator_exception
      Wavefront::Exception::InvalidExternalLinkId
    end

    def do_create
      body = { name:              options[:'<name>'],
               template:          options[:'<template>'],
               description:       options[:'<description>'],
               metricFilterRegex: options[:metricregex],
               sourceFilterRegex: options[:sourceregex],
               pointFilterRegex:  point_filter_regexes }

      wf.create(body.select { |_k, v| v })
    end

    def search_key
      :extlink
    end

    private

    def point_filter_regexes
      ret = options[:pointregex].each_with_object({}) do |r, a|
        begin
          k, v = r.split('=', 2)
          a[k.to_sym] = v
        rescue StandardError
          puts "cannot parse point regex '#{r}'. Skipping."
        end
      end

      ret.empty? ? nil : ret
    end
  end
end
