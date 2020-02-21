# frozen_string_literal: true

require_relative 'base'
require_relative '../constants'

module WavefrontCli
  module Subcommand
    #
    # Methods for search subcommand. Also used by things which do a search
    # behind the scenes, like listing Dashboard favourites
    #
    class Search < Base
      include WavefrontCli::Constants

      def run!(cond)
        wfs = sdk_search_object
        query = conds_to_query(cond)
        wfs.search(@calling_class.search_key, query, range_hash)
      end

      # Perform a search based on the given condition
      # @param object [Symbol] :dashboard, :alert etc
      # @param cond [Array[String]] with elements of the form key=value
      # @param opts [Hash] options for SDK search call
      #
      def cond_search(object, cond, opts)
        sdk_search_object.search(object, conds_to_query(cond), opts)
      end

      # Turn a list of search conditions into an API query
      #
      # @param conds [Array]
      # @return [Array[Hash]]
      #
      def conds_to_query(conds)
        conds.map do |cond|
          key, value = cond.split(SEARCH_SPLIT, 2)
          { key: key, value: value }.merge(matching_method(cond))
        end
      end

      # @param cond [String] a search condition, like "key=value"
      # @return [Hash] of matchingMethod and negated
      #
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      def matching_method(cond)
        case cond
        when /^\w+~/
          { matchingMethod: 'CONTAINS', negated: false }
        when /^\w+!~/
          { matchingMethod: 'CONTAINS', negated: true }
        when /^\w+=/
          { matchingMethod: 'EXACT', negated: false }
        when /^\w+!=/
          { matchingMethod: 'EXACT', negated: true }
        when /^\w+\^/
          { matchingMethod: 'STARTSWITH', negated: false }
        when /^\w+!\^/
          { matchingMethod: 'STARTSWITH', negated: true }
        else
          raise(WavefrontCli::Exception::UnparseableSearchPattern, cond)
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      def sdk_search_object
        require 'wavefront-sdk/search'
        Wavefront::Search.new(@calling_class.mk_creds, @calling_class.mk_opts)
      end

      # If the user has specified --all, override any limit and offset
      # values
      #
      # rubocop:disable Metrics/MethodLength
      def range_hash
        offset_key = :offset

        if options[:all]
          limit  = :all
          offset = ALL_PAGE_SIZE
        elsif options[:cursor]
          offset_key = :cursor
          limit = options[:limit]
          offset = options[:cursor]
        else
          limit  = options[:limit]
          offset = options[:offset]
        end

        { limit: limit, offset_key => offset }
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
