# frozen_string_literal: true

require_relative '../helpers/load_file'

module WavefrontCli
  module Subcommand
    #
    # Stuff to import an object
    #
    class Import
      attr_reader :wf, :options

      def initialize(calling_class, options)
        @calling_class = calling_class
        @wf = calling_class.wf
        @options = options
        @message = 'IMPORTED'
      end

      def run!
        errs = 0

        [raw_input].flatten.each do |obj|
          resp = import_object(obj)
          next if options[:noop]

          errs += 1 unless resp.ok?
          puts import_message(obj, resp)
        end

        exit errs
      end

      private

      def raw_input
        WavefrontCli::Helper::LoadFile.new(options[:'<file>']).load
      end

      def import_message(obj, resp)
        format('%-15<id>s %-10<status>s %<message>s',
               id: obj[:id] || obj[:url],
               status: resp.ok? ? @message : 'FAILED',
               message: resp.status.message)
      end

      def import_object(raw)
        raw = preprocess_rawfile(raw) if respond_to?(:preprocess_rawfile)
        prepped = @calling_class.import_to_create(raw)

        if options[:upsert]
          import_upsert(raw, prepped)
        elsif options[:update]
          @message = 'UPDATED'
          import_update(raw)
        else
          wf.create(prepped)
        end
      end

      def import_upsert(raw, prepped)
        update_call = import_update(raw)

        if update_call.ok?
          @message = 'UPDATED'
          return update_call
        end

        puts 'update failed, inserting' if options[:verbose] || options[:debug]
        wf.create(prepped)
      end

      def import_update(raw)
        wf.update(raw[:id], raw, false)
      end
    end
  end
end
