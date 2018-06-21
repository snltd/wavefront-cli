require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'user' API.
  #
  class User < WavefrontCli::Base
    def do_list
      wf.list
    end

    def do_grant
      wf.grant(options[:'<id>'], options[:'<privilege>'])
    end

    def do_revoke
      wf.revoke(options[:'<id>'], options[:'<privilege>'])
    end

    def import_to_create(raw)
      raw['emailAddress'] = raw['identifier']
      raw.delete_if { |k, _v| k == 'customer' || k == 'identifier' }
    end
  end
end
