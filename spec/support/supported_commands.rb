require_relative '../constants'

class SupportedCommands
  attr_reader :cmd_dir

  def initialize
    @cmd_dir = ROOT + 'lib' + 'wavefront-cli' + 'commands'
  end

  def all
    files = cmd_dir.children.select do |f|
      f.extname == '.rb' && f.basename.to_s != 'base.rb'
    end

    files.map { |f| f.basename.to_s.chomp('.rb') }
  end
end
