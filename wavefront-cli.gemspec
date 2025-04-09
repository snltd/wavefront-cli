# frozen_string_literal: true

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

  gem.add_dependency 'docopt', '~> 0.6'
  gem.add_dependency 'inifile', '~> 3.0'
  gem.add_dependency 'wavefront-sdk', '~> 8.0'

  gem.required_ruby_version = Gem::Requirement.new('>= 3.1.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
