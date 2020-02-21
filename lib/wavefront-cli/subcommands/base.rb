# frozen_string_literal: true

module WavefrontCli
  module Subcommand
    #
    # Standard setup for Subcommand classes
    #
    class Base
      attr_reader :wf, :options

      def initialize(calling_class, options)
        @calling_class = calling_class
        @wf = calling_class.wf
        @options = options
        post_initialize if respond_to?(:post_initialize)
      end
    end
  end
end
