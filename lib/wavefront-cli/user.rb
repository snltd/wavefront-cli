require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'user' API.
  #
  class User < WavefrontCli::Base
    def do_list
      @response = :raw
      wf.list
    end

    def do_describe
      @response = :verbose
      wf.describe(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_grant
      wf.grant(options[:'<id>'], options[:'<privilege>'])
    end

    def do_revoke
      wf.revoke(options[:'<id>'], options[:'<privilege>'])
    end
  end
end
