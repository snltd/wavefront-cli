#!/usr/bin/env ruby

require 'pathname'
word = Pathname.new(__FILE__).basename.to_s.sub('_spec.rb', '')
require_relative(File.join('../../../lib/wavefront-cli/commands',
                 Pathname.new(__FILE__).basename.to_s.sub('_spec.rb', '')))
require_relative './base_spec'

class WavefrontCommmandWriteTest < WavefrontCommmandBaseTest
  def setup
    @wf = WavefrontCommandWrite.new
    @col_width = 25
    @skip_cmd = %r{write (point|file)}
  end
end
