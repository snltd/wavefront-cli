=begin
    Copyright 2015 Wavefront Inc.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
   limitations under the License.

=end

module Wavefront
  #
  # Various things which help around the place
  #
  module Mixins
    def interpolate_schema(label, host, prefix_length)
      label_parts = label.split('.')
      interpolated = []
      interpolated << label_parts.shift(prefix_length)
      interpolated << host
      interpolated << label_parts
      interpolated.flatten!
      interpolated.join('.')
    end

    def parse_time(t)
      #
      # Return a time as an integer, however it might come in.
      #
      return t if t.is_a?(Integer)
      return t.to_i if t.is_a?(Time)
      return t.to_i if t.is_a?(String) && t.match(/^\d+$/)
      DateTime.parse("#{t} #{Time.now.getlocal.zone}").to_time.utc.to_i
    rescue
      raise "cannot parse timestamp '#{t}'."
    end

    def time_to_ms(t)
      #
      # Return the time as milliseconds since the epoch
      #
      return false unless t.is_a?(Integer)
      (t.to_f * 1000).round
    end

    def hash_to_qs(payload)
      #
      # Make a properly escaped query string out of a key: value
      # hash.
      #
      URI.escape(payload.map { |k, v| [k, v].join('=') }.join('&'))
    end

    def uri_concat(*args)
      args.join('/').squeeze('/')
    end

    def call_get(uri)
      if verbose || noop
        puts 'GET ' + uri.to_s
        puts 'HEADERS ' + headers.to_s
      end
      return if noop
      RestClient.get(uri.to_s, headers)
    end

    def call_post(uri, query = nil, ctype = 'text/plain')
      h = headers
      if verbose || noop
        puts 'POST ' + uri.to_s
        puts 'QUERY ' + query if query
        puts 'HEADERS ' + h.to_s
      end
      return if noop

      RestClient.post(uri.to_s, query,
                      h.merge(:'Content-Type' => ctype,
                              :Accept         => 'application/json'))
    end

    def call_delete(uri)
      if verbose || noop
        puts 'DELETE ' + uri.to_s
        puts 'HEADERS ' + headers.to_s
      end
      return if noop
      RestClient.delete(uri.to_s, headers)
    end

    def load_file(path)
      #
      # Give it a path to a file (as a string) and it will return the
      # contents of that file as a Ruby object. Automatically detects
      # JSON and YAML. Raises an exception if it doesn't look like
      # either.
      #
      file = Pathname.new(path)
      raise 'Import file does not exist.' unless file.exist?

      if file.extname == '.json'
        JSON.parse(IO.read(file))
      elsif file.extname == '.yaml' || file.extname == '.yml'
        YAML.load(IO.read(file))
      else
        raise 'Unsupported file format.'
      end
    end
  end
end
