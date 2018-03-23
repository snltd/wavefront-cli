require 'securerandom'
require 'json'

module WavefrontHclOutput
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
      format('resource "wavefront_%s" "%s" {', resource_name,
             SecureRandom.uuid)
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
      resp.select { |k, v| hcl_fields.include?(k) }
    end

    # Format each key-value pair
    # @param k [String] key
    # @param v [Any] value
    # @return [String]
    #
    def handler(k, v)
      key_handler = "khandle_#{k}".to_sym
      value_handler = "vhandle_#{k}".to_sym
      quote_handler = "qhandle_#{k}".to_sym
      k = send(key_handler) if respond_to?(key_handler)
      v = send(value_handler, v) if respond_to?(value_handler)

      quote_handler = :quote_value unless respond_to?(quote_handler)

      format('  %s = %s', k.to_snake, send(quote_handler, v))
    end

    # Tags need to be in an array. They aren't always called "tags"
    # by the API.
    # @param v [Array,Hash,String] tags
    # @return [Array] of soft-quoted tags
    #
    def vhandle_tags(v)
      v = v.values if v.is_a?(Hash)
      v = Array(v).flatten
    end

    # Some values need to be quoted, some need to be escaped etc
    # etc.
    # @param v [Object] value
    # @return [String]
    #
    def quote_value(v)
      case v.class.to_s.to_sym
      when :String
        format('"%s"', v.gsub(/\"/, '\"'))
      else
        v
      end
    end
  end
end
