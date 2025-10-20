require 'rspec'
require 'rspec_boolean'
require 'crypt/gpgme'

RSpec.describe Crypt::GPGME::Engine do
  subject{ described_class.new(true) }

  example 'object basic functionality' do
    expect(subject).to respond_to(:object)
    expect(subject.object).to be_a(Crypt::GPGME::Structs::EngineInfo)
  end

  example 'to_hash basic functionality' do
    expect(subject).to respond_to(:to_hash)
    expect(subject.to_hash).to be_a(Hash)
  end

  example 'to_hash returns expected result' do
    expect(subject.to_hash).to include(:protocol, :file_name, :version, :req_version, :home_dir)
  end

  example 'protocol basic functionality' do
    expect(subject).to respond_to(:protocol)
    expect(subject.protocol).to be_a(Integer)
    expect(subject.protocol(as: 'string')).to be_a(String)
  end

  example 'protocol returns expected result' do
    expect(subject.protocol).to eq(0)
    expect(subject.protocol(as: 'string')).to eq('OpenPGP')
  end

  example 'file_name basic functionality' do
    expect(subject).to respond_to(:file_name)
    expect(subject.file_name).to be_a(String).or be_nil
  end

  example 'version basic functionality' do
    expect(subject).to respond_to(:version)
    expect(subject.version).to be_a(String).or be_nil
  end

  example 'req_version basic functionality' do
    expect(subject).to respond_to(:req_version)
    expect(subject.req_version).to be_a(String).or be_nil
  end

  example 'home_dir basic functionality' do
    expect(subject).to respond_to(:home_dir)
    expect(subject.home_dir).to be_a(String).or be_nil
  end

  context 'singleton methods' do
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
end
