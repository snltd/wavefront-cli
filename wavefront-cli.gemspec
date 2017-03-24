require 'pathname'

lib = Pathname.new(__FILE__).dirname.realpath + 'lib'
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wavefront-cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'wavefront-cli'
  spec.version       = Wavefront::Client::VERSION
  spec.authors       = ['Robert Fisher']
  spec.email         = ['slackboy@gmail.com']
  spec.description   = %q(An simple abstraction for talking to Wavefront in Ruby.)
  spec.homepage      = 'https://github.com/snltd/wavefront-cli'
  spec.license       = 'Apache License 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
  spec.add_development_dependency 'yard',  '~> 0.9.5'

  spec.add_dependency 'rest-client', '>= 1.6.7', '< 1.8'
  spec.required_ruby_version = Gem::Requirement.new('>= 1.9.3')
end
