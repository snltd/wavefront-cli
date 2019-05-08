require_relative 'base'
require_relative 'command_mixins/tag'
require_relative 'command_mixins/acl'

module WavefrontCli
  #
  # CLI coverage for the v2 'dashboard' API.
  #
  class Dashboard < WavefrontCli::Base
    include WavefrontCli::Mixin::Tag
    include WavefrontCli::Mixin::Acl

    def list_filter(list)
      return list unless options[:nosystem]
      list.tap { |l| l.response.items.delete_if { |d| d[:systemOwned] } }
    end

    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    # rubocop:disable Metrics/AbcSize
    def do_delete
      cannot_noop!

      word = if wf.describe(options[:'<id>']).status.code == 200
               'Soft'
             else
               'Permanently'
             end

      puts "#{word} deleting dashboard '#{options[:'<id>']}'."
      wf.delete(options[:'<id>'])
    end
    # rubocop:enable Metrics/AbcSize

    def do_history
      wf.history(options[:'<id>'])
    end

    def do_queries
      resp, data = one_or_all

      queries = data.each_with_object({}) do |d, a|
        a[d.id] = extract_values(d, 'query')
      end

      resp.tap { |r| r.response.items = queries }
    end

    def do_favs
      require 'wavefront-sdk/search'
      wfs = Wavefront::Search.new(mk_creds, mk_opts)
      query = conds_to_query(['favorite=true'])
      wfs.search(:dashboard, query, limit: :all, sort_field: :id)
    end

    def do_fav
      wf.favorite(options[:'<id>'])
      do_favs
    end

    def do_unfav
      wf.unfavorite(options[:'<id>'])
      do_favs
    end
  end
end
