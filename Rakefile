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

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'yard'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :install  do
  sh 'gem build ./wavefront-client.gemspec'
  sh 'gem install wavefront-client-*.gem --no-rdoc --no-ri'
  sh 'rm wavefront-client-*.gem'
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end
