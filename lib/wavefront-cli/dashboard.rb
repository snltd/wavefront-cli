require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'dashboard' API.
  #
  class Dashboard < WavefrontCli::Base
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

    def do_acls
      wf.acls([options[:'<id>']])
    end

    def do_acl_clear
      wf.acl_set(options[:'<id>'], [], [id: everyone_id, name: 'Everyone'])
      do_acls
    end

    def do_acl_grant
      acl_action(:grant_to)
    end

    def do_acl_revoke
      acl_action(:revoke_from)
    end

    # Based on command-line options, return an array describing the
    # users or groups (entities) which will be granted or revoked a
    # privilege.
    # @return [Array] [type_of_entity, [Hash]...]
    #
    def acl_entities
      acl_type = options[:modify] ? :modify : :view

      if options[:user]
        [:users, user_lists(acl_type, options[:'<name>'])]
      else
        [:groups, group_lists(acl_type, options[:'<name>'])]
      end
    end

    # Make a list of users to be given to the SDK ACL methods. Users
    # are defined as a Hash, with keys :id and :name.
    # @param acl_type [Symbol] :view or :modify
    # @param users [Array] user names
    # @return [Array[Hash]]
    #
    def user_lists(acl_type, users)
      { view: [], modify: [] }.tap do |l|
        l[acl_type] = users.map { |u| { id: u, name: u } }
      end
    end

    # Generate arrays ready for passing to the SDK acl methods
    # @return see #user_lists, but name and id are not the same.
    #
    def group_lists(acl_type, groups)
      { view: [], modify: [] }.tap do |l|
        l[acl_type] = groups.each_with_object([]) do |g, a|
          name = group_name(g)

          if name.nil?
            puts "Cannot find group with id '#{g}'."
            next
          end

          a.<< ({ id: g, name: name })
        end
      end
    end

    private

    # When given an ACL action (grant or revoke), call the right
    # method with the right arguments.
    # @param action [Symbol] :grant_to or :revoke_from
    # @return [Wavefront::Response]
    #
    def acl_action(action)
      entity_type, entities = acl_entities

      resp = send(format('%s_%s', action, entity_type),
                  options[:'<id>'],
                  entities)

      print_status(resp.status)
      do_acls
    end

    # The #grant_to_ and #revoke_from_ methods are called by
    # #acl_action, and speak to the SDK. They all return a
    # Wavefront::Response object.
    #
    def grant_to_users(id, lists)
      wf.acl_add(id, lists[:view], lists[:modify])
    end

    def revoke_from_users(id, lists)
      wf.acl_delete(id, lists[:view], lists[:modify])
    end

    def grant_to_groups(id, lists)
      wf.acl_add(id, lists[:view], lists[:modify])
    end

    def revoke_from_groups(id, lists)
      wf.acl_delete(id, lists[:view], lists[:modify])
    end

    def print_status(status)
      puts status.message unless status.message.empty?
    rescue NoMethodError
      nil
    end

    # Get the name of a user group, given the ID.
    # @param group_id [String] UUID of a group
    # @return [String, Nil] name of group, nil if it does not exist
    #
    def group_name(group_id)
      require 'wavefront-sdk/usergroup'
      wfs = Wavefront::UserGroup.new(mk_creds, mk_opts)
      wfs.describe(group_id).response.name
    rescue RuntimeError
      nil
    end

    # @return [String] UUID of 'Everyone' group
    # @raise WavefrontCli::Exception::UserGroupNotFound if group
    #   does not exist. This is caught in the controller.
    #
    def everyone_id
      require 'wavefront-sdk/search'
      wfs = Wavefront::Search.new(mk_creds, mk_opts)
      query = conds_to_query(['name=Everyone'])
      wfs.search(:usergroup, query).response.items.first.id
    rescue RuntimeError
      raise WavefrontCli::Exception::UserGroupNotFound, 'Everyone'
    end
  end
end
