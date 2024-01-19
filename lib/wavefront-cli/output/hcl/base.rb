# frozen_string_literal: true

require 'securerandom'
require 'json'

module WavefrontHclOutput
  #
  # Output stuff for Hashicorp Configuration Language
  #
  class Base
    attr_reader :resp, :options

    def initialize(resp, options)
      @resp = resp
      @options = options
    end

    def run
      puts open_output
      required_fields.each { |k, v| puts handler(k, v) }
      puts close_output
    end

    # Fields which the provider requires.
    # @return [Array] of strings
    #
    def hcl_fields
      []
    end

    def open_output
      format('resource "wavefront_%<name>s" "%<uuid>s" {',
             name: resource_name,
             uuid: SecureRandom.uuid)
    end

    def close_output
      '}'
    end

    # Override this if the provider calls a resource something other
    # than the name of the inheriting class
    #
    def resource_name
      options[:class]
    end

    # The provider can only handle certain keys. Each class should
    # provide a list of things it knows the provider requires. If it
    # does not, we display everything
    #
    def required_fields
      return resp if hcl_fields.empty?

      resp.select { |k, _v| hcl_fields.include?(k) }
    end

    # Format each key-value pair
    # @param key [String] key
    # @param val [Any] value
    # @return [String]
    #
    def handler(key, val)
      key_handler = :"khandle_#{key}"
      value_handler = :"vhandle_#{key}"
      quote_handler = :"qhandle_#{key}"
      key = send(key_handler) if respond_to?(key_handler)
      val = send(value_handler, val) if respond_to?(value_handler)

      quote_handler = :quote_value unless respond_to?(quote_handler)

      format('  %<key>s = %<value>s',
             key: key.to_snake,
             value: send(quote_handler, val))
    end

    # Tags need to be in an array. They aren't always called "tags"
    # by the API.
    # @param val [Array,Hash,String] tags
    # @return [Array] of soft-quoted tags
    #
    def vhandle_tags(val)
      val = val.values if val.is_a?(Hash)
      Array(val).flatten
    end

    # Some values need to be quoted, some need to be escaped etc
    # etc.
    # @param val [Object] value
    # @return [String]
    #
    def quote_value(val)
      case val.class.to_s.to_sym
      when :String
        format('"%<value>s"', value: val.gsub('"', '\"'))
      else
        val
      end
    end
  end
end
