require 'rspec'
require 'rspec_boolean'
require 'fakefs/spec_helpers'
require 'tmpdir'
require 'crypt/gpgme'

RSpec.configure do |config|
  config.include FakeFS::SpecHelpers, fakefs: true
  config.around(:example, :tempfs) do |example|
    original_home = ENV['GNUPGHOME']

    Dir.mktmpdir do |tmpdir|
      ENV['GNUPGHOME'] = tmpdir

      example.metadata['tmpdir'] = tmpdir
      example.run

      ENV['GNUPGHOME'] = original_home
    end
  end
end
