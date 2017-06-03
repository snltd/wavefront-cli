require_relative './base'

module WavefrontDisplay
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < Base

    def do_list
      long_output [:id, :minutes, :target, :status, :tags, :hostsUsed,
                   :condition, :displayExpression, :severity,
                   :additionalInformation]
    end

    def do_import
      puts "Imported alert."
      long_output
    end

    def do_delete
      puts "Deleted alert '#{options[:'<id>']}'."
    end

    def do_undelete
      puts "Undeleted alert '#{options[:'<id>']}'."
    end

    def do_snooze
      puts "Snoozed alert '#{options[:'<id>']}'."
    end

    def do_unsnooze
      puts "Unsnoozed alert '#{options[:'<id>']}'."
    end

    def do_summary
      kw = data.keys.map(&:size).max + 2

      data.sort.reject { |_k, v| v.zero? }.each do |k, v|
        puts format("%-#{kw}s%s", k, v)
      end
    end

    def do_tag_add
      puts "Added tag."
    end

    def do_tag_delete
      puts "Deleted tag."
    end

    def do_tag_clear
      puts "Cleared tags on #{options[:'<id>']}."
    end

    def do_tag_set
      puts "Set tags."
    end

    def do_tags
      if data.empty?
        puts "No tags set on #{options[:'<id>']}."
      else
        data.sort.each { |t| puts t }
      end
    end
  end
end
