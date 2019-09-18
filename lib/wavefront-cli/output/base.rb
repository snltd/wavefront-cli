# frozen_string_literal: true

module WavefrontOutput
  #
  # WavefrontCli::Base looks for a class WavefrontOutput::Format
  # where 'Format' is something like 'Json', or 'Yaml'. If it finds
  # that class it creates a new instance, passing through the
  # response object (@resp) and options hash (@options), then  calls
  # the #run method.
  #
  # All those classes are an extension of this one. Some, like Json
  # or Yaml, are generic, and dump a straight translation of the
  # response object. Others, like Hcl or Wavefront, have subclasses
  # which deal with the output of specific commands.
  #
  class Base
    attr_reader :resp, :options, :cmd

    def initialize(resp = {}, options = {})
      @cmd = options[:class]
      @options = options
      @resp = filtered_response(resp)
    end

    # We used to call #run directly, but now we use this wrapper to
    # make it easier to test the #_run methods.
    #
    def run
      puts _run
    end

    def _run
      command_class.run
    end

    def filtered_response(resp)
      return resp unless options[:itemsonly]

      items_only(resp)
    end

    def items_only(resp)
      if allow_items_only?
        return resp[:items] if resp.key?(:items)

        raise(WavefrontCli::Exception::UnsupportedOutput,
              'API response does not contain items object.')
      end

      raise(WavefrontCli::Exception::UnsupportedOutput,
            format("'%s' format does not support items-only output.",
                   my_format))
    end

    def my_format
      self.class.name.split('::').last.downcase
    end

    def command_class_name
      format('Wavefront%sOutput::%s', my_format.capitalize, cmd.capitalize)
    end

    def command_file
      File.join(my_format, cmd)
    end

    def command_class
      require_relative command_file
      Object.const_get(command_class_name).new(resp, options)
    end

    def allow_items_only?
      false
    end
  end
end
