module WavefrontCli
  module Mixin
    #
    # Standard ACL commands. Mix this module in to get ACL support.
    #
    module Acl
      def do_acls
        wf.acls([options[:'<id>']])
      end

      def do_acl_clear
        wf.acl_set(options[:'<id>'], [], [everyone_id])
        do_acls
      end

      def do_acl_grant
        return grant_view if options[:view]
        return grant_modify if options[:modify]

        raise WavefrontCli::Exception::InsufficientData
      end

      def do_acl_revoke
        return revoke_view if options[:view]
        return revoke_modify if options[:modify]

        raise WavefrontCli::Exception::InsufficientData
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

      def grant_modify
        wf.acl_add(options[:'<id>'], [], options[:'<name>'])
        do_acls
      end

      def grant_view
        wf.acl_add(options[:'<id>'], options[:'<name>'], [])
        do_acls
      end

      def revoke_view
        wf.acl_delete(options[:'<id>'], options[:'<name>'], [])
        do_acls
      end

      def revoke_modify
        wf.acl_delete(options[:'<id>'], [], options[:'<name>'])
        do_acls
      end

      # @param action [Symbol] :grant_to or :revoke_from
      # @return [Wavefront::Response]
      #
      def _acl_action(action)
        entity_type, entities = acl_entities

        resp = send(format('%s_%s', action, entity_type),
                    options[:'<id>'],
                    entities)

        print_status(resp.status)
        do_acls
      end

      def print_status(status)
        puts status.message unless status.message.empty?
      rescue NoMethodError
        nil
      end
    end
  end
end
