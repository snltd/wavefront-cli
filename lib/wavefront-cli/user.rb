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
      @verbose_response = true
      wf.describe(options[:'<user>'])
    end

    def do_delete
      wf.delete(options[:'<user>'])
    end

    def do_grant
      wf.grant(options[:'<user>'], options[:'<privilege>'])
    end

    def do_revoke
      wf.revoke(options[:'<user>'], options[:'<privilege>'])
    end
  end
end
