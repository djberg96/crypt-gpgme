#######################################################################
# engine_spec.rb
#
# Specs for the Crypt::GPGME::Engine class.
#######################################################################
require 'spec_helper'

RSpec.describe Crypt::GPGME::Engine do
  describe '.check_version' do
    example 'basic functionality' do
      expect(described_class).to respond_to(:check_version)
    end

    example 'returns a boolean' do
      expect(described_class.check_version).to be_boolean
    end

    example 'returns true when version is valid' do
      expect(described_class.check_version).to be true
    end

    example 'returns false when version requirement is too high' do
      expect(described_class.check_version(99999)).to be false
    end

    example 'only accepts a single argument' do
      expect{ described_class.check_version(1, 2) }.to raise_error(ArgumentError)
    end

    example 'only accepts an integer argument' do
      expect{ described_class.check_version('foo') }.to raise_error(TypeError)
    end
  end
end
