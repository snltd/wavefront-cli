require_relative 'base'

module WavefrontDisplay
  #
  # Format human-readable output for notification targets.
  #
  class Notificant < Base
    def do_list_brief
      multicolumn(:id, :method, :description)
    end

    def do_describe
      readable_time(:createdEpochMillis, :updatedEpochMillis)
      long_output
    end

    def do_test
      puts 'Testing notification.'
    end
  end
end
