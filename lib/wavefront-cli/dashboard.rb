require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'dashboard' API.
  #
  class Dashboard < WavefrontCli::Base
    def list_filter(list)
      return list unless options[:nosystem]
      list.tap { |l| l.response.items.delete_if { |d| d[:systemOwned] } }
    end

    def do_describe
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_delete
      word = if wf.describe(options[:'<id>']).status.code == 200
               'Soft'
             else
               'Permanently'
             end

      puts "#{word} deleting dashboard '#{options[:'<id>']}'."
      wf.delete(options[:'<id>'])
    end

    def do_history
      wf.history(options[:'<id>'])
    end

    def do_queries
      resp, data = one_or_all

      queries = data.each_with_object({}) do |d, a|
        a[d.id] = extract_values(d, 'query')
      end

      resp.tap { |r| r.response.items = queries }
    end

    # @param obj [Object] the thing to search
    # @param key [String, Symbol] the key to search for
    # @param aggr [Array] values of matched keys
    # @return [Array]
    #
    def extract_values(obj, key, aggr = [])
      if obj.is_a?(Hash)
        obj.each_pair do |k, v|
          if k == key && !v.to_s.empty?
            aggr.<< v
          else
            extract_values(v, key, aggr)
          end
        end
      elsif obj.is_a?(Array)
        obj.each { |e| extract_values(e, key, aggr) }
      end

      aggr
    end
  end
end
