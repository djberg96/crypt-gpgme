#######################################################################
# algorithm_spec.rb
#
# Specs for the Crypt::GPGME::Algorithm class.
#######################################################################
require 'spec_helper'

RSpec.describe Crypt::GPGME::Algorithm do
  describe '.pubkey_algorithm_name' do
    example 'basic functionality' do
      expect(described_class).to respond_to(:pubkey_algorithm_name)
    end

    example 'returns a String for valid algorithm' do
      expect(described_class.pubkey_algorithm_name(1)).to be_a(String)
    end

    example 'returns expected value for DSA' do
      expect(described_class.pubkey_algorithm_name(Crypt::GPGME::GPGME_PK_DSA)).to eq('DSA')
    end

    example 'returns expected value for RSA' do
      expect(described_class.pubkey_algorithm_name(Crypt::GPGME::GPGME_PK_RSA)).to eq('RSA')
    end

    example 'returns nil for invalid algorithm' do
      expect(described_class.pubkey_algorithm_name(9999999)).to be_nil
    end
  end

  describe '.hash_algorithm_name' do
    example 'basic functionality' do
      expect(described_class).to respond_to(:hash_algorithm_name)
    end

    example 'returns a String for valid algorithm' do
      expect(described_class.hash_algorithm_name(1)).to be_a(String)
    end

    example 'returns expected value for MD5' do
      expect(described_class.hash_algorithm_name(Crypt::GPGME::GPGME_MD_MD5)).to eq('MD5')
    end

    example 'returns expected value for SHA256' do
      expect(described_class.hash_algorithm_name(Crypt::GPGME::GPGME_MD_SHA256)).to eq('SHA256')
    end

    example 'returns nil for invalid algorithm' do
      expect(described_class.hash_algorithm_name(9999999)).to be_nil
    end
  end
end
