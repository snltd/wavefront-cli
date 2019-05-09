module WavefrontCli
  module Mixin
    #
    # Standard ACL commands
    #
    module Acl
      def do_acls
        wf.acls([options[:'<id>']])
      end

      def do_acl_clear
        wf.acl_set(options[:'<id>'],
                   [],
                   [id: everyone_id, name: 'Everyone'])
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

      # Make a list of users to be given to the SDK ACL methods. Users
      # are defined as a Hash, with keys :id and :name.
      # @param acl_type [Symbol] :view or :modify
      # @param users [Array] user names
      # @return [Hash]
      #
      def user_lists(acl_type, users)
        { view: [], modify: [] }.tap do |l|
          l[acl_type] = users
        end
      end
      alias group_lists user_lists

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
    end
  end
end
