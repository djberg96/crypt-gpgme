require 'rspec'
require 'rspec_boolean'
require 'fakefs/spec_helpers'
require 'tmpdir'
require 'crypt/gpgme'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
  config.around(:example, :tempfs) do |example|
    Dir.mktmpdir do |tmpdir|
      example.metadata['tmpdir'] = tmpdir
      example.run
    end
  end
end
