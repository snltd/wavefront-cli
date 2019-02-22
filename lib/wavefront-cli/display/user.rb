require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for user management.
  #
  class User < Base
    def do_list_brief
      data.each { |user| puts user[:identifier] }
    end

    def do_groups
      if data.userGroups.empty?
        puts 'User does not belong to any groups.'
      else
        data.userGroups.each { |u| puts format('%s (%s)', u[:id], u[:name]) }
      end
    end

    def do_create
      puts format("Created user '%s'.\nPermission groups\n%s\n" \
                  "User groups\n%s",
                  data.response[:identifier],
                  groups_as_string(data.response.groups),
                  user_groups_as_string(data.response.userGroups))
    end

    def groups_as_string(groups)
      return '  <none>' if groups.empty?
      data.response.groups.map { |g| format('  %s', g) }.join("\n  ")
    end

    def user_groups_as_string(groups)
      return '  <none>' if groups.empty?
      groups.map { |g| format('  %s (%s)', g[:name], g[:id]) }.join("\n")
    end

    def do_delete
      puts format('Deleted %s', options[:'<user>'].join(', '))
    end
  end
end
