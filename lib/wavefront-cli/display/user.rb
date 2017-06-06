require_relative './base'

module WavefrontDisplay

  # Format human-readable output for webhooks.
  #
  class User < Base
    def do_list_brief
      data.each { |user| puts user[:identifier] }
    end
  end
end
