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
      terse_output(:id, :description)
    end

    # Filter out the Wavefront cluster sources
    #
    def drop_cluster_sources
      data.sort_by! { |k, _v| k }
      return if options[:all]
      data.delete_if { |k| k.id =~ /prod-[\da-f]{2}-/ }
    end
  end
end
