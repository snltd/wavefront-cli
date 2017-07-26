require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for webhooks.
  #
  class Source < Base
    def do_list
      drop_cluster_sources
      long_output
    end

    def do_list_brief
      drop_cluster_sources
      multicolumn(:id, :description)
    end

    def do_search_brief
      multicolumn(:id)
    end

    # Filter out the Wavefront cluster sources. Don't sort them, or
    # using offset and cursor becomes confusing.
    #
    def drop_cluster_sources
      return if options[:all]
      data.delete_if { |k| k.id =~ /prod-[\da-f]{2}-/ }
    end
  end
end
