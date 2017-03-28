require_relative './base'

module WavefrontCli
  #
  # CLI coverage for the v2 'alert' API.
  #
  class Alert < WavefrontCli::Base
    include WavefrontCli::Constants

    def do_list
      @verbose_response = true
      @flags[:short] = options[:short]
      wf.list(options[:start] || 0, options[:limit] || 100)
    end

    def humanize_list_output(data)
      if flags[:short]
        data.each { |a| puts "#{a['id']}  #{a['name']}" }
      else
        HumanOutput.new(data)
      end
    end

    def do_describe
      @verbose_response = true
      wf.describe(options[:'<id>'], options[:version])
    end

    def do_import
      raw = load_file(options[:'<file>'])

      begin
        prepped = import_to_create(raw)
      rescue => e
        puts e if options[:debug]
        raise 'could not parse input.'
      end

      wf.create(prepped)
    end

    def import_to_create(raw)
      #
      # Take a previously exported alert, and construct a hash which
      # create() can use to re-create it.
      #
      ret = {
        name:      raw['name'],
        condition: raw['condition'],
        minutes:   raw['minutes'],
        target:    raw['target'],
        severity:  raw['severity'],
      }

      if raw.key?('displayExpression')
        ret[:displayExpression] = raw['displayExpression']
      end

      if raw.key?('resolveAfterMinutes')
        ret[:resolveMinutes] = raw['resolveAfterMinutes']
      end

      if raw.key?('customerTagsWithCounts')
        ret[:sharedTags] = raw['customerTagsWithCounts'].keys
      end

      if raw.key?('additionalInformation')
        ret[:additionalInformation] = raw['additionalInformation']
      end

      ret
    end

    def do_snooze
      wf.snooze(options[:'<id>'], options[:time])
    end

    def do_unsnooze
      wf.snooze(options[:'<id>'])
    end

    def do_delete
      wf.delete(options[:'<id>'])
    end

    def do_undelete
      wf.undelete(options[:'<id>'])
    end

    def do_summary
      @verbose_response = true
      wf.summary
    end

    # Display the counts of alerts in various states. If a state has no
    # alerts, it is skipped.
    #
    # @param data [Hash] hash of alerts
    #
    def humanize_summary_output(data)
      kw = data.keys.map(&:size).max + 2
      data.sort.reject { |k, v| v == 0 }.each do |k, v|
        puts format("%-#{kw}s%s", k, v)
      end
    end

    def do_history
      @verbose_response = true
      wf.history(options[:'<id>'])
    end

    def do_tags
      @verbose_response = true
      wf.tags(options[:'<id>'])
    end

    def do_tag_add
      wf.tag_add(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_delete
      wf.tag_delete(options[:'<id>'], options[:'<tag>'])
    end

    def do_tag_set
      wf.tag_set(options[:'<id>'], Array(options[:'<tag>']))
    end

    def do_tag_clear
      wf.tag_set(options[:'<id>'], [])
    end

    def humanize_tags_output(data)
      data.sort.each { |t| puts t }
    end
  end
end

=begin
require 'wavefront-sdk/alert'
require_relative './base'
require_relative './constants'
require 'json'
require 'yaml'
require 'pp'
require 'time'

class WavefrontCli::Alert < WavefrontCli::Base
  include WavefrontCli::Constants
  attr_accessor :options, :arguments, :wfa

  def run
    raise 'Missing token.' if ! @options[:token] || @options[:token].empty?
    raise 'Missing query.' if arguments.empty?
    valid_format?(@options[:alertformat].to_sym)

    @wfa = Wavefront::Alert.new(@options[:token], @options[:endpoint],
                                @options[:debug], {
      noop: @options[:noop], verbose: @options[:verbose]})

    if options[:export]
      export_alert(options[:'<timestamp>'])
      return
    end

    if options[:import]
      import_alert
      return
    end

    query = arguments[0].to_sym
    valid_state?(wfa, query)
    options = { host: @options[:endpoint] }

    if @options[:shared]
      options[:shared_tags] = @options[:shared].delete(' ').split(',')
    end

    if @options[:private]
      options[:private_tags] = @options[:private].delete(' ').split(',')
    end

    begin
      result = wfa.send(query, options)
    rescue => e
      puts e if @options[:debug]
      raise 'Unable to execute query.'
    end

    format_result(result, @options[:alertformat].to_sym)
    exit
  end

  def export_alert(id)
    begin
      resp = wfa.get_alert(id)
    rescue => e
      puts e if @options[:debug]
      raise 'Unable to retrieve alert.'
    end

    return if options[:noop]

    case options[:alertformat].to_sym
    when :json
      puts JSON.pretty_generate(resp)
    when :yaml
      puts resp.to_yaml
    when :human
      puts humanize([resp])
    else
      puts 'unknown output format.'
    end
  end

  def format_result(result, format)
    #
    # Call a suitable method to display the output of the API call,
    # which is JSON.
    #
    return if noop

    case format
    when :ruby
      pp result
    when :json
      puts JSON.pretty_generate(JSON.parse(result))
    when :yaml
      puts JSON.parse(result).to_yaml
    when :human
      puts humanize(JSON.parse(result))
    else
      raise "Invalid output format '#{format}'. See --help for more detail."
    end
  end

  def valid_format?(fmt)
    fmt = fmt.to_sym if fmt.is_a?(String)

    unless WavefrontCli::Base::ALERT_FORMATS.include?(fmt)
      raise 'Output format must be one of: ' +
        WavefrontCli::Base::ALERT_FORMATS.join(', ') + '.'
    end
    true
  end

  def valid_state?(wfa, state)
    #
    # Check the alert type we've been given is valid. There needs to
    # be a public method in the 'alerting' class for every one.
    #
    states = %w(active affected_by_maintenance all invalid snoozed)

    unless states.include?(state.to_s)
      raise "State must be one of: #{states.join(', ')}."
    end
    true
  end

  def humanize(alerts)
    #
    # Selectively display alert information in an easily
    # human-readable format. I have chosen not to display certain
    # fields which I don't think are useful in this context. I also
    # wish to put the fields in order. Here are the fields I want, in
    # the order I want them.
    #
    row_order = %w(name created severity condition displayExpression
                   minutes resolveAfterMinutes updated alertStates
                   metricsUsed hostsUsed additionalInformation)

    # build up an array of lines then turn it into a string and
    # return it
    #
    # Most things get printed with the human_line() method, but some
    # data needs special handling. To do that, just add a method
    # called human_line_key() where key is something in row_order,
    # and it will be found.
    #
    x = alerts.map do |alert|
      row_order.map do |key|
        lm = "human_line_#{key}"
        if self.respond_to?(lm)
          self.method(lm.to_sym).call(key, alert[key])
        else
          human_line(key, alert[key])
        end
      end.<< ''
    end
  end

  def human_line(k, v)
    ('%-22s%s' % [k, v]).rstrip
  end

  def human_line_created(k, v)
    #
    # The 'created' and 'updated' timestamps are in epoch
    # milliseconds
    #
    human_line(k, "#{Time.at(v / 1000)} (#{v})")
  end

  def human_line_updated(k, v)
    human_line_created(k, v)
  end

  def human_line_hostsUsed(k, v)
    #
    # Put each host on its own line, indented. Does this by
    # returning an array.
    #
    return k unless v && v.is_a?(Array) && ! v.empty?
    v.sort!
    [human_line(k, v.shift)] + v.map {|el| human_line('', el)}
  end

  def human_line_metricsUsed(k, v)
    human_line_hostsUsed(k, v)
  end

  def human_line_alertStates(k, v)
    human_line(k, v.join(','))
  end

  def human_line_additionalInformation(k, v)
    human_line(k, indent_wrap(v))
  end
=end


