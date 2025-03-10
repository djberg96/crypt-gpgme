#######################################################################
# crypt_gpgme_spec.rb
#
# Specs for the crypt-gpgme library.
#######################################################################
require 'rspec'
require 'rspec_boolean'
require 'crypt/gpgme'

RSpec.describe Crypt::GPGME do
  example 'version is set to expected value' do
    expect(Crypt::GPGME::VERSION).to eq('0.1.0')
  end

  context Crypt::GPGME::Algorithm do
    example 'algorithm_name basic functionality' do
      expect(described_class).to respond_to(:algorithm_name)
      expect(described_class.algorithm_name(1)).to be_a(String)
    end
  end

  context Crypt::GPGME::Engine do
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

  context 'FFI' do
    before(:context) do
      require 'mkmf-lite'
    end

    let(:dummy){ Class.new{ extend Mkmf::Lite } }

    #example 'engine_info is the expected size' do
    #  expect(Crypt::GPGME::Structs::EngineInfo.size).to eq(dummy.check_sizeof('struct _gpgme_engine_info', 'gpgme.h'))
    #end
  end
end
