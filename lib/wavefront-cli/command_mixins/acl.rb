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
    end
  end
end
