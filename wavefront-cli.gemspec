# frozen_string_literal: true

require 'pathname'
require 'date'
require_relative 'lib/wavefront-cli/version'

Gem::Specification.new do |gem|
  gem.name          = 'wavefront-cli'
  gem.version       = WF_CLI_VERSION

  gem.summary       = 'CLI for Wavefront API v2'
  gem.description   = 'CLI for Wavefront (wavefront.com) API v2 '

  gem.authors       = ['Robert Fisher']
  gem.email         = 'services@id264.net'
  gem.homepage      = 'https://github.com/snltd/wavefront-cli'
  gem.license       = 'BSD-2-Clause'

  gem.bindir        = 'bin'
  gem.files         = `git ls-files`.split("\n")
  gem.executables   = 'wf'
  gem.require_paths = %w[lib]

  gem.add_runtime_dependency 'docopt', '~> 0.6'
  gem.add_runtime_dependency 'inifile', '~> 3.0'
  gem.add_runtime_dependency 'wavefront-sdk', '~> 8.0'

  gem.add_development_dependency 'minitest', '~> 5.17'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rubocop', '1.43'
  gem.add_development_dependency 'rubocop-minitest', '~> 0.26'
  gem.add_development_dependency 'rubocop-performance', '~> 1.15'
  gem.add_development_dependency 'rubocop-rake', '~> 0.6'
  gem.add_development_dependency 'spy', '~> 1.0'
  gem.add_development_dependency 'webmock', '~> 3.18'
  gem.add_development_dependency 'yard', '~> 0.9'

  gem.required_ruby_version = Gem::Requirement.new('>= 2.7.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
