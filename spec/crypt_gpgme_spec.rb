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

  context 'FFI' do
    before(:context) do
      require 'mkmf-lite'
    end

    let(:dummy){ Class.new{ extend Mkmf::Lite } }
    let(:header) { 'gpgme.h' }
    let(:path){ RbConfig::CONFIG['host_os'] =~ /darwin/i ? '/opt/homebrew/include' : '/usr/local/include' }

    example 'engine_info is the expected size' do
      expect(Crypt::GPGME::Structs::EngineInfo.size).to eq(dummy.check_sizeof('struct _gpgme_engine_info', header, path))
    end

    example 'key is the expected size' do
      expect(Crypt::GPGME::Structs::Key.size).to eq(dummy.check_sizeof('struct _gpgme_key', header, path))
    end

    example 'subkey is the expected size' do
      expect(Crypt::GPGME::Structs::Subkey.size).to eq(dummy.check_sizeof('struct _gpgme_subkey', header, path))
    end

    example 'keysig is the expected size' do
      expect(Crypt::GPGME::Structs::KeySig.size).to eq(dummy.check_sizeof('struct _gpgme_key_sig', header, path))
    end

    example 'userid is the expected size' do
      expect(Crypt::GPGME::Structs::UserId.size).to eq(dummy.check_sizeof('struct _gpgme_user_id', header, path))
    end

    example 'tofuinfo is the expected size' do
      expect(Crypt::GPGME::Structs::TofuInfo.size).to eq(dummy.check_sizeof('struct _gpgme_tofu_info', header, path))
    end

    example 'signotation is the expected size' do
      expect(Crypt::GPGME::Structs::SigNotation.size).to eq(dummy.check_sizeof('struct _gpgme_sig_notation', header, path))
    end
  end
end
