# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'

module WavefrontCli
  module Subcommand
    #
    # Stuff to handle data dumping
    #
    class Dump < Base
      include WavefrontCli::Constants

      def run!
        if options[:format] == 'yaml'
          @calling_class.ok_exit(dump_yaml)
        elsif options[:format] == 'json'
          @calling_class.ok_exit(dump_json)
        else
          abort format("Dump format must be 'json' or 'yaml'. " \
                       "(Tried '%<format>s')", options)
        end
      end

      def dump_yaml
        JSON.parse(@calling_class.item_dump_call.to_json).to_yaml
      end

      def dump_json
        @calling_class.item_dump_call.to_json
      end
    end
  end
end
