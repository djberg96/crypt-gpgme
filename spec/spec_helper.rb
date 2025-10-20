require 'rspec'
require 'rspec_boolean'
require 'fakefs/spec_helpers'
require 'crypt/gpgme'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
end
