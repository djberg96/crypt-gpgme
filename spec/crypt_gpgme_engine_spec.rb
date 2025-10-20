require 'rspec'
require 'rspec_boolean'
require 'crypt/gpgme'

RSpec.describe Crypt::GPGME::Engine do
  example 'check_version basic functionality' do
    expect(described_class).to respond_to(:check_version)
    expect(described_class.check_version).to be_boolean
  end

  example 'check_version returns the expected value' do
    expect(described_class.check_version).to be true
    expect(described_class.check_version(99999)).to be false
  end

  example 'check_version only accepts a single, integer argument' do
    expect{ described_class.check_version(1, 2) }.to raise_error(ArgumentError)
    expect{ described_class.check_version('foo') }.to raise_error(TypeError)
  end
end
