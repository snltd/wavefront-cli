require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for dashboards.
  #
  class Dashboard < Base
    def do_list
      long_output
    end

    def do_describe
      drop_fields(:parameterDetails)
      readable_time(:createdEpochMillis, :updatedEpochMillis)
      data[:sections] = data[:sections].map { |s| s[:name] }
      long_output
    end

    def do_queries
      if options[:brief]
        @data = data.to_h.values.flatten.map { |q| { query: q } }
        multicolumn(:query)
      else
        long_output
      end
    end

    def do_fav
      puts "Added #{options[:'<id>']} to favourites."
    end

    def do_unfav
      puts "Removed #{options[:'<id>']} from favourites."
    end

    def do_acls
      data.each do |dash|
        display_acl('view and modify', dash[:modifyAcl])
        display_acl('view', dash[:viewAcl])
      end
    end

    def display_acl(title, acl_data)
      puts title

      if acl_data.empty?
        puts '  <none>'
      else
        acl_data.each { |e| puts format('  %<name>s (%<id>s)', e) }
      end
    end
  end
end
