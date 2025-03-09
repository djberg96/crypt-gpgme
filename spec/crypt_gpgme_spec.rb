#######################################################################
# crypt_gpgme_spec.rb
#
# Specs for the crypt-gpgme library.
#######################################################################
require 'rspec'
require 'crypt/gpgme'

RSpec.describe Crypt::GPGME do
  example 'version is set to expected value' do
    expect(Crypt::GPGME::VERSION).to eq('0.1.0')
  end

  context 'FFI' do
    before(:context) do
      require 'mkmf-lite'
    end

    let(:dummy){ Class.new{ extend Mkmf::Lite } }

    example 'engine_info is the expected size' do
      expect(Crypt::GPGME::Structs::EngineInfo.size).to eq(dummy.check_sizeof('gpgme_engine_info_t', 'gpgme.h'))
    end
  end
end
