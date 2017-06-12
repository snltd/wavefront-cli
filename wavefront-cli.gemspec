require 'pathname'
require 'date'
require 'English'

require_relative 'lib/wavefront-cli/version'

Gem::Specification.new do |gem|
  gem.name          = 'wavefront-cli'
  gem.version       = WF_CLI_VERSION
  gem.date          = Date.today.to_s

  gem.summary       = 'CLI for Wavefront API v2'
  gem.description   = 'CLI for Wavefront (wavefront.com) API v2 '

  gem.authors       = ['Robert Fisher']
  gem.email         = 'slackboy@gmail.com'
  gem.homepage      = 'https://github.com/snltd/wavefront-cli'
  gem.license       = 'BSD-2-Clause'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = %w(lib)

  gem.add_runtime_dependency 'docopt', '0.5.0'
  gem.add_runtime_dependency 'wavefront-sdk', '0.1.2'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'yard', '~> 0.9.5'
  gem.add_development_dependency 'rubocop', '~> 0.47.0'
  gem.add_development_dependency 'webmock', '~> 2.3', '>= 2.3.2'
  gem.add_development_dependency 'minitest', '~> 5.8', '>= 5.8.0'
  gem.add_development_dependency 'spy', '~> 0.4.0'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.2.0')
end
