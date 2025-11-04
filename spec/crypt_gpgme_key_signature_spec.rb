require 'spec_helper'

RSpec.describe Crypt::GPGME::KeySignature do
  subject{ described_class.new(true) }

  #context 'initializer' do
  #end

  context 'methods' do
    example 'object basic functionality' do
      expect(subject).to respond_to(:object)
      expect(subject.object).to be_a(Crypt::GPGME::Structs::KeySig)
    end

    example 'to_hash basic functionality' do
      expect(subject).to respond_to(:to_hash)
      expect(subject.to_hash).to be_a(Hash)
    end

    example 'pubkey_algo basic functionality' do
      expect(subject).to respond_to(:pubkey_algo)
      expect(subject.pubkey_algo).to be_a(Integer)
    end

    example 'keyid basic functionality' do
      expect(subject).to respond_to(:keyid)
      expect(subject.keyid).to be_a(String).or be_nil
    end

    example 'timestamp basic functionality' do
      expect(subject).to respond_to(:timestamp)
      expect(subject.timestamp).to be_a(Integer).or be_nil
    end

    example 'expires basic functionality' do
      expect(subject).to respond_to(:expires)
      expect(subject.expires).to be_a(Integer).or be_nil
    end

    example 'expires basic functionality' do
      expect(subject).to respond_to(:expires)
      expect(subject.expires).to be_a(Integer).or be_nil
    end

    example 'status basic functionality' do
      expect(subject).to respond_to(:status)
      expect(subject.status).to be_a(Integer).or be_nil
    end

    example 'uid basic functionality' do
      expect(subject).to respond_to(:uid)
      expect(subject.uid).to be_a(String).or be_nil
    end

    example 'email basic functionality' do
      expect(subject).to respond_to(:email)
      expect(subject.email).to be_a(String).or be_nil
    end

    example 'comment basic functionality' do
      expect(subject).to respond_to(:comment)
      expect(subject.comment).to be_a(String).or be_nil
    end

    example 'sig_class basic functionality' do
      expect(subject).to respond_to(:sig_class)
      expect(subject.sig_class).to be_a(Integer).or be_nil
    end

    example 'notations basic functionality' do
      expect(subject).to respond_to(:notations)
    end

    example 'trust_scope basic functionality' do
      expect(subject).to respond_to(:trust_scope)
      expect(subject.trust_scope).to be_a(String).or be_nil
    end
  end
end
