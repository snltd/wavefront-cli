require 'wavefront/writer'
require 'wavefront/cli'
require 'socket'
#
# Push datapoints into Wavefront, via a proxy. This class deals in
# single points. It cannot batch, or deal with files or streams of
# data. This is because it depends on the very simple 'writer'
# class, which cannot be significantly changed, so as to maintain
# backward compatibility.
#
class Wavefront::Cli::Write < Wavefront::Cli
  include Wavefront::Constants
  include Wavefront::Mixins

  def validate_opts
    #
    # Unlike all the API methods, we don't need a token here
    #
    abort 'Please supply a proxy endpoint.' unless options[:proxy]
  end

  def run
    valid_value?(options[:'<value>'])
    valid_metric?(options[:'<metric>'])
    ts = options[:time] ? parse_time(options[:time]) : false

    [:proxy, :host].each do |h|
      fail Wavefront::Exception::InvalidHostname unless valid_host?(h)
    end

    write_opts = {
      agent_host:   options[:proxy],
      host_name:    options[:host],
      metric_name:  options[:'<metric>'],
      point_tags:   prep_tags(options[:tag]),
      timestamp:    ts,
      noop:         options[:noop]
    }

    write_metric(options[:'<value>'].to_i, options[:'<metric>'], write_opts)
  end

  def write_metric(value, name, opts)
    wf = Wavefront::Writer.new(opts)
    wf.write(value, name, opts)
  end

  def valid_host?(hostname)
    #
    # quickly make sure a hostname looks vaguely sensible
    #
    hostname.match(/^[\w\.\-]+$/) && hostname.length < 1024
  end

  def valid_value?(value)
    #
    # Values, it seems, will always come in as strings. We need to
    # cast them to numbers. I don't think there's any reasonable way
    # to allow exponential notation.
    #
    unless value.is_a?(Numeric) || value.match(/^-?\d*\.?\d*$/) ||
           value.match(/^-?\d*\.?\d*e\d+$/)
      fail Wavefront::Exception::InvalidMetricValue
    end
    true
  end

  def valid_metric?(metric)
    #
    # Apply some common-sense rules to metric paths. Check it's a
    # string, and that it has at least one dot in it. Don't allow
    # through odd characters or whitespace.
    #
    begin
      fail unless metric.is_a?(String) &&
                  metric.split('.').length > 1 &&
                  metric.match(/^[\w\-\._]+$/) &&
                  metric.length < 1024
    rescue
      raise Wavefront::Exception::InvalidMetricName
    end
    true
  end

  def prep_tags(tags)
    #
    # Takes an array of key=value tags (as produced by docopt) and
    # turns it into an array of [key, value] arrays (as required
    # by various of our own methods). Anything not of the form
    # key=val is dropped.
    #
    return [] unless tags.is_a?(Array)
    tags.map { |t| t.split('=') }.select { |e| e.length == 2 }
  end
end
