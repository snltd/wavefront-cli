require_relative './base'

module WavefrontDisplay
  #
  # Format human-readable output for cloud integrations.
  #
  class Integration < Base
    def do_list_brief
      multicolumn(:id, :name, :description)
    end
  end
end
