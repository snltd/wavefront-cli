require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'user' API.
  #
  class User < WavefrontCli::Base
    def do_list
      wf.list
    end

    def do_delete
      wf.delete_users(options[:'<user>'])
    end

    def do_create
      wf_user_id?(options[:'<id>'])
      wf.create(user_body, options[:email])
    end

    alias do_groups do_describe

    def do_join
      wf.add_groups_to_user(options[:'<id>'], options[:'<group>'])
    end

    def do_leave
      wf.remove_groups_from_user(options[:'<id>'], options[:'<group>'])
    end

    def do_grant
      wf.grant(options[:'<id>'], options[:'<privilege>'])
    end

    def do_revoke
      wf.revoke(options[:'<id>'], options[:'<privilege>'])
    end

    def do_invite
      wf_user_id?(options[:'<id>'])
      wf.invite([user_body])
    end

    def import_to_create(raw)
      { emailAddress: raw['items']['identifier'],
        groups:       raw['items']['groups'] }.tap do |r|

        if raw['items'].key?('userGroups')
          r['userGroups'] = raw['items']['userGroups'].map { |g| g['id'] }
        end
      end
    end

    # Object used to create and invite users.
    #
    def user_body
      { emailAddress: options[:'<id>'],
        groups:       options[:permission],
        userGroups:   options[:group] }
    end

    # Because of the way docopt works, we have to call the user ID
    # parameter something else on the delete command. This means the
    # automatic validtion doesn't work, and we have to do it
    # ourselves.
    #
    def extra_validation
      options[:'<user>'].each { |u| validate_user(u) }
    end

    def validate_user(user)
      wf_user_id?(user)
    rescue Wavefront::Exception::InvalidUserId
      abort failed_validation_message(user)
    end
  end
end
