# frozen_string_literal: true

require_relative '../exception'

module WavefrontCli
  module Helper
    #
    # Give it a path to a file (as a string) and it will return the
    # contents of that file as a Ruby object. Automatically detects
    # JSON and YAML. Raises an exception if it doesn't look like
    # either. If path is '-' then it will read STDIN.
    #
    # @param path [String] the file to load
    # @return [Hash] a Ruby object of the loaded file
    # @raise WavefrontCli::Exception::UnsupportedFileFormat if the
    #   filetype is unknown.
    # @raise pass through any error loading or parsing the file
    #
    class LoadFile
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def load
        return load_from_stdin if path == '-'

        file = Pathname.new(path)
        extname = file.extname.downcase

        raise WavefrontCli::Exception::FileNotFound unless file.exist?

        return load_json(file) if extname == '.json'
        return load_yaml(file) if %w[.yaml .yml].include?(extname)

        raise WavefrontCli::Exception::UnsupportedFileFormat
      end

      private

      def load_json(file)
        read_json(File.read(file))
      end

      def load_yaml(file)
        read_yaml(File.read(file))
      end

      # Read STDIN and return a Ruby object, assuming that STDIN is
      # valid JSON or YAML. This is a dumb method, it does no
      # buffering, so STDIN must be a single block of data. This
      # appears to be a valid assumption for use-cases of this CLI.
      #
      # @return [Object]
      # @raise Wavefront::Exception::UnparseableInput if the input
      #   does not parse
      #
      def load_from_stdin
        raw = $stdin.read

        if raw.start_with?('---')
          read_yaml(raw)
        else
          read_json(raw)
        end
      rescue RuntimeError
        raise Wavefront::Exception::UnparseableInput
      end

      def read_json(io)
        JSON.parse(io, symbolize_names: true)
      end

      def read_yaml(io)
        YAML.safe_load(io, symbolize_names: true)
      end
    end
  end
end
