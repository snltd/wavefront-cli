require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'dashboard' API.
  #
  class Dashboard < WavefrontCli::Base
    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_delete
      print (if wf.describe(options[:'<id>']).status.code == 200
              'Soft'
            else
              'Permanently'
            end)

      puts " deleting dashboard '#{options[:'<id>']}'."
      wf.delete(options[:'<id>'])
    end

    def do_history
      wf.history(options[:'<id>'])
    end
  end
end
