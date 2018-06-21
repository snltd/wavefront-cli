require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for user management.
  #
  class User < Base
    def do_list_brief
      data.each { |user| puts user[:identifier] }
    end

    def do_delete
      puts "Deleted user '#{options[:'<id>']}."
    end
  end
end
