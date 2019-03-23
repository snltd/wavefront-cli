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

    def do_favs
      if data.empty?
        puts 'No favourites.'
      else
        multicolumn(:id)
      end
    end

    alias do_fav do_favs
    alias do_unfav do_favs

    def do_acls
      data.each do |dash|
        display_acl('view and modify', dash[:modifyAcl])
        display_acl('view', dash[:viewAcl])
      end
    end

    alias do_acl_grant do_acls
    alias do_acl_revoke do_acls
    alias do_acl_clear do_acls

    private

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
