require 'rspec'
require 'rspec_boolean'
require 'fakefs/spec_helpers'
require 'crypt/gpgme'
require 'tmpdir'

# Load all support files
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
  config.include_context 'with temporary gpg home', :tempfs
end
