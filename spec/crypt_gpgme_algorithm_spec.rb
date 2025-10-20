require 'spec_helper'

RSpec.describe Crypt::GPGME::Algorithm do
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
