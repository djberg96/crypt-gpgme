#######################################################################
# structs_spec.rb
#
# Specs for the Crypt::GPGME::Structs FFI bindings.
#######################################################################
require 'spec_helper'

RSpec.describe 'Crypt::GPGME::Structs' do
  before(:context) do
    require 'mkmf-lite'
  end

  let(:dummy) { Class.new { extend Mkmf::Lite } }
  let(:header) { 'gpgme.h' }
  let(:path) do
    if RbConfig::CONFIG['host_os'] =~ /darwin/i
      '/opt/homebrew/include'
    else
      '/usr/local/include'
    end
  end

  describe Crypt::GPGME::Structs::EngineInfo do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_engine_info', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end

  describe Crypt::GPGME::Structs::Key do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_key', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end

  describe Crypt::GPGME::Structs::Subkey do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_subkey', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end

  describe Crypt::GPGME::Structs::KeySig do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_key_sig', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end

  describe Crypt::GPGME::Structs::UserId do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_user_id', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end

  describe Crypt::GPGME::Structs::TofuInfo do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_tofu_info', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end

  describe Crypt::GPGME::Structs::SigNotation do
    example 'is the expected size' do
      expected_size = dummy.check_sizeof('struct _gpgme_sig_notation', header, path)
      expect(described_class.size).to eq(expected_size)
    end
  end
end
