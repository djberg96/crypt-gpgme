require 'spec_helper'

RSpec.describe Crypt::GPGME::Key do
  subject{ described_class.new(true) }

  #context 'initializer' do
  #end

  context 'methods' do
    example 'object basic functionality' do
      expect(subject).to respond_to(:object)
      expect(subject.object).to be_a(Crypt::GPGME::Structs::Key)
    end

    example 'to_hash basic functionality' do
      expect(subject).to respond_to(:to_hash)
      expect(subject.to_hash).to be_a(Hash)
    end

    example 'protocol basic functionality' do
      expect(subject).to respond_to(:protocol)
      expect(subject.protocol).to be_a(Integer).or be_nil
    end

    example 'protocol with as argument returns expected value' do
      expect(subject.protocol(as: 'string')).to be_a(String).or be_nil
    end

    example 'issuer_serial basic functionality' do
      expect(subject).to respond_to(:issuer_serial)
      expect(subject.issuer_serial).to be_a(String).or be_nil
    end

    example 'issuer_name basic functionality' do
      expect(subject).to respond_to(:issuer_name)
      expect(subject.issuer_name).to be_a(String).or be_nil
    end

    example 'chain_id basic functionality' do
      expect(subject).to respond_to(:chain_id)
      expect(subject.chain_id).to be_a(String).or be_nil
    end

    example 'chain_id basic functionality' do
      expect(subject).to respond_to(:chain_id)
      expect(subject.chain_id).to be_a(String).or be_nil
    end

    example 'owner_trust basic functionality' do
      expect(subject).to respond_to(:owner_trust)
      expect(subject.owner_trust).to be_a(Integer).or be_nil
    end

    example 'keylist_mode basic functionality' do
      expect(subject).to respond_to(:keylist_mode)
      expect(subject.keylist_mode).to be_a(Integer).or be_nil
    end

    example 'fpr basic functionality' do
      expect(subject).to respond_to(:fpr)
      expect(subject.fpr).to be_a(String).or be_nil
    end

    example 'fingerprint is an alias for fpr' do
      expect(subject.method(:fpr)).to eq(subject.method(:fingerprint))
    end

    example 'last_update basic functionality' do
      expect(subject).to respond_to(:last_update)
      expect(subject.last_update).to be_a(Integer).or be_nil
    end

    example 'last_update basic functionality' do
      expect(subject).to respond_to(:last_update)
      expect(subject.last_update).to be_a(Integer).or be_nil
    end

    example 'subkeys basic functionality' do
      expect(subject).to respond_to(:subkeys)
      expect(subject.subkeys).to be_a(Array)
    end

    example 'uids basic functionality' do
      expect(subject).to respond_to(:uids)
      expect(subject.uids).to be_a(Array)
    end

    example 'revocation_keys basic functionality' do
      expect(subject).to respond_to(:revocation_keys)
      expect(subject.revocation_keys).to be_a(Array)
    end
  end
end
