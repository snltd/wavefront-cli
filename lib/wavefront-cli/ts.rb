#!/usr/bin/env ruby

#     Copyright 2015 Wavefront Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
#    limitations under the License.

require 'wavefront/client'
require 'wavefront/cli'
require 'pp'
require 'json'
require 'date'

class Wavefront::Cli::Ts < Wavefront::Cli
  include Wavefront::Mixins
  attr_accessor :options, :arguments

  def run
    raise 'Please supply a query.' if @arguments.empty?
    query = @arguments[0]

    if @options[:minutes]
      granularity = 'm'
    elsif @options[:hours]
      granularity = 'h'
    elsif @options[:seconds]
      granularity = 's'
    elsif @options[:days]
      granularity = 'd'
    else
      raise "You must specify a granularity of either --seconds, --minutes --hours or --days. See --help for more information."
    end

    unless Wavefront::Client::FORMATS.include?(@options[:format].to_sym)
      raise "The output format must be one of: #{Wavefront::Client::FORMATS.join(', ')}."
    end

    options = Hash.new
    options[:response_format] = @options[:format].to_sym
    options[:prefix_length] = @options[:prefixlength].to_i

    if @options[:start]
      options[:start_time] = Time.at(parse_time(@options[:start]))
    end

    if @options[:end]
      options[:end_time] = Time.at(parse_time(@options[:end]))
    end

    wave = Wavefront::Client.new(@options[:token], @options[:endpoint], @options[:debug], { noop: @options[:noop], verbose: @options[:verbose]})

    if noop
      wave.query(query, granularity, options)
      return
    end

    case options[:response_format]
    when :json
      pp wave.query(query, granularity, options)
    when :raw
      puts wave.query(query, granularity, options)
    when :graphite
      puts wave.query(query, granularity, options).graphite.to_json
    when :human
      puts wave.query(query, granularity, options).human
    else
      pp wave.query(query, granularity, options)
    end

    exit 0
  end
end
