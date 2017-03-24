require 'socket'
require 'pathname'
require 'wavefront/cli'
require 'wavefront/batch_writer'
#
# Push datapoints into Wavefront, via a proxy. Uses the
# 'batch_writer' class.
#
class Wavefront::Cli::BatchWrite < Wavefront::Cli
  attr_reader :opts, :sock, :fmt, :wf

  include Wavefront::Constants
  include Wavefront::Mixins

  def validate_opts
    #
    # Unlike all the API methods, we don't need a token here
    #
    abort 'Please supply a proxy endpoint.' unless options[:proxy]
  end

  def run
    unless valid_format?(options[:infileformat])
      raise 'Invalid format string.'
    end

    file = options[:'<file>']
    setup_opts(options)

    if options.key?(:infileformat)
      setup_fmt(options[:infileformat])
    else
      setup_fmt
    end

    @wf = Wavefront::BatchWriter.new(options)

    begin
      wf.open_socket
    rescue
      raise 'unable to connect to proxy'
    end

    begin
      if file == '-'
        STDIN.each_line { |l| wf.write(process_line(l.strip)) }
      else
        process_filedata(load_data(Pathname.new(file)))
      end
    ensure
      wf.close_socket
    end

    puts "Point summary: " + (%w(sent unsent rejected).map do |p|
      [wf.summary[p.to_sym], p].join(' ')
    end.join(', ')) + '.'
  end

  def setup_fmt(fmt = DEFAULT_INFILE_FORMAT)
    @fmt = fmt.split('')
  end

  def setup_opts(options)
    @opts = {
      prefix:   options[:metric] || '',
      source:   options[:host] || Socket.gethostname,
      tags:     tags_to_hash(options[:tag]),
      endpoint: options[:proxy],
      port:     options[:port],
      verbose:  options[:verbose],
      noop:     options[:noop],
    }
  end

  def tags_to_hash(tags)
    #
    # Turn a docopt array of key=value tags into a hash for the
    # batch_writer class. If key or value are quoted, we remove the
    # quotes.
    #
    tags = [tags] if tags.is_a?(String)
    tags = {} unless tags.is_a?(Array)

    tags.each_with_object({}) do |t, m|
      k, v = t.split('=', 2)
      m[k.gsub(/^["']|["']$/, '').to_sym] =
        v.to_s.gsub(/^["']|["']$/, '') if v
    end
  end

  def load_data(file)
    begin
      IO.read(file)
    rescue
      raise "Cannot open file '#{file}'." unless file.exist?
    end
  end

  def process_filedata(data)
    #
    # we know what order the fields are in from the format string,
    # which contains 't', 'm', and 'v' in some order
    #
    data.split("\n").each { |l| wf.write(process_line(l)) }
  end

  def valid_format?(fmt)
    # The format string must contain a 'v'. It must not contain
    # anything other than 'm', 't', 'T' or 'v', and the 'T', if
    # there, must be at the end. No letter must appear more than
    # once.
    #
    fmt.include?('v') && fmt.match(/^[mtv]+T?$/) && fmt ==
      fmt.split('').uniq.join
  end

  def valid_line?(l)
    #
    # Make sure we have the right number of columns, according to
    # the format string. We want to take every precaution we can to
    # stop users accidentally polluting their metric namespace with
    # junk.
    #
    # If the format string says we are expecting point tags, we may
    # have more columns than the length of the format string.
    #
    ncols = l.split.length

    if fmt.include?('T')
      return false unless ncols >= fmt.length
    else
      return false unless ncols == fmt.length
    end

    true
  end

  def valid_timestamp?(ts)
    #
    # Another attempt to stop the user accidentally sending nonsense
    # data. See if the time looks valid. We'll assume anything before
    # 2000/01/01 or after a year from now is wrong. Arbitrary, but
    # there has to be a cut-off somewhere.
    #
    (ts.is_a?(Integer) || ts.match(/^\d+$/)) &&
      ts.to_i > 946684800 && ts.to_i < (Time.now.to_i + 31557600)
  end

  def valid_value?(val)
    val.is_a?(Numeric) || (val.match(/^-?[\d\.e]+$/) && val.count('.') < 2)
  end

  def process_line(l)
    #
    # Process a line of input, as described by the format string
    # held in opts[:fmt]. Produces a hash suitable for batch_writer
    # to send on.
    #
    # We let the user define most of the fields, but anything beyond
    # what they define is always assumed to be point tags. This is
    # because you can have arbitrarily many of those for each point.
    #
    return true if l.empty?
    m_prefix = opts[:prefix]
    chunks = l.split(/\s+/, fmt.length)

    begin
      raise 'wrong number of fields' unless valid_line?(l)

      begin
        v = chunks[fmt.index('v')]

        if valid_value?(v)
          point = { value: v.to_f }
        else
          raise "invalid value '#{v}'"
        end

      rescue TypeError
        raise "no value in '#{l}'"
      end


      # The user can supply a time. If they have told us they won't
      # be, we'll use the current time.
      #

      point[:ts] = begin
        ts = chunks[fmt.index('t')]

        if valid_timestamp?(ts)
          Time.at(parse_time(ts))
        else
          raise "invalid timestamp '#{ts}'"
        end

      rescue TypeError
        Time.now.utc.to_i
      end

      # The source is normally the local hostname, but the user can
      # override that.

      point[:source] = begin
        chunks[fmt.index('s')]
      rescue TypeError
        opts[:source]
      end

      # The metric path can be in the data, or passed as an option, or
      # both. If the latter, then we assume the option is a prefix,
      # and concatenate the value in the data.
      #
      begin
        m = chunks[fmt.index('m')]
        point[:path] = m_prefix.empty? ? m : [m_prefix, m].join('.')
      rescue TypeError
        if m_prefix
          point[:path] = m_prefix
        else
          raise "metric path in '#{l}'"
        end
      end
    rescue => e
      puts "WARNING: #{e}. Skipping."
      return false
    end

    if fmt.last == 'T'
      point[:tags] =
        tags_to_hash(chunks.last.split(/\s(?=(?:[^"]|"[^"]*")*$)/))
    end

    point
  end
end
