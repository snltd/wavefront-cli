require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for sources.
  #
  class Source < Base
    def do_list
      massage_data
      long_output
    end

    def do_list_brief
      massage_data
      multicolumn(:id, :description)
    end

    def massage_data
      return if options[:all]
      drop_cluster_sources
      drop_hidden_sources
    end

    def do_search_brief
      multicolumn(:id)
    end

    # Filter out any sources with 'hidden=true'
    #
    def drop_hidden_sources
      data.delete_if { |k| k.tags['hidden'] == true }
    end

    # Filter out the Wavefront cluster sources. Don't sort them, or
    # using offset and cursor becomes confusing.
    #
    def drop_cluster_sources
      data.delete_if { |k| k.id =~ /prod-[\da-f]{2}-/ }
    end
  end
end
