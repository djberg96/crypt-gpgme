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
    example 'pubkey_algorithm_name basic functionality' do
      expect(described_class).to respond_to(:pubkey_algorithm_name)
      expect(described_class.pubkey_algorithm_name(1)).to be_a(String)
    end

    example 'pubkey_algorithm_name returns expected value' do
      expect(described_class.pubkey_algorithm_name(Crypt::GPGME::GPGME_PK_DSA)).to eq('DSA')
      expect(described_class.pubkey_algorithm_name(Crypt::GPGME::GPGME_PK_RSA)).to eq('RSA')
      expect(described_class.pubkey_algorithm_name(9999999)).to be_nil
    end

    example 'hash_algorithm_name basic functionality' do
      expect(described_class).to respond_to(:hash_algorithm_name)
      expect(described_class.pubkey_algorithm_name(1)).to be_a(String)
    end

    example 'hash_algorithm_name returns expected value' do
      expect(described_class.hash_algorithm_name(Crypt::GPGME::GPGME_MD_MD5)).to eq('MD5')
      expect(described_class.hash_algorithm_name(Crypt::GPGME::GPGME_MD_SHA256)).to eq('SHA256')
      expect(described_class.hash_algorithm_name(9999999)).to be_nil
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

  context Crypt::GPGME::Context do
    subject{ described_class.new }

    after do
      subject.release
    end

    example 'armor? basic functionality' do
      expect(subject).to respond_to(:armor?)
      expect(subject.armor?).to be_boolean
    end

    example 'armor= basic functionality' do
      expect(subject).to respond_to(:armor=)
      expect(subject.armor=true).to be_boolean
    end

    example 'armor? returns expected value' do
      expect(subject.armor?).to be(false)
      subject.armor=true
      expect(subject.armor?).to be(true)
    end
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
