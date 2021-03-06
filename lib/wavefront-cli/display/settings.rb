# frozen_string_literal: true

require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for external links.
  #
  class Settings < Base
    def do_list_permissions
      data.sort_by! { |p| p[:groupName] }
      options[:long] ? long_output : multicolumn(:groupName)
    end

    def do_list_usergroups
      if options[:long]
        readable_time_arr(:createdEpochMillis)
        long_output
      else
        multicolumn(:id, :name)
      end
    end
  end
end
