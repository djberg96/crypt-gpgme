require 'rake'
require 'rake/clean'
require 'rbconfig'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

CLEAN.include("**/*.rbc", "**/*.rbx", "**/*.gem", "**/*.lock")

namespace :gem do
  desc "Create the crypt-gpgme gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('crypt-gpgme.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc "Install the crypt-gpgme gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

RuboCop::RakeTask.new

desc "Run the test suite"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
