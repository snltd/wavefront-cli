require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'settings' API.
  #
  class Settings < WavefrontCli::Base
    def do_list_permissions
      wf.permissions
    end

    def do_show_preferences
      wf.preferences
    end

    def do_default_usergroups
      wf.default_user_groups
    end

    def do_set
      body = options[:'<key=value>'].each_with_object({}) do |o, a|
        k, v = o.split('=', 2)
        next unless v && !v.empty?

        if %w[invitePermissions defaultUserGroups].include?(k)
          v = v.include?(',') ? v.split(',') : [v]
        end

        a[k] = v
      end

      pp body

      wf.update_preferences(body)
    end
  end
end
