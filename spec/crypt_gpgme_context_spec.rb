require 'spec_helper'

RSpec.describe Crypt::GPGME::Context do
  subject{ described_class.new }

  after do
    subject.release
  end

  context 'armor' do
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

  context 'flags' do
    example 'get_flag basic functionality' do
      expect(subject).to respond_to(:get_flag)
      expect(subject.get_flag('redraw')).to be_a(String)
    end

    example 'get_flag returns expected value' do
      expect(subject.get_flag('redraw')).to eq('')
    end

    example 'set_flag basic functionality' do
      expect(subject).to respond_to(:set_flag)
      expect(subject.set_flag('redraw', '')).to be_a(Hash)
    end

    example 'set_flag returns expected value' do
      expect(subject.set_flag('redraw', '')).to eq({'redraw' => ''})
    end
  end

  context 'engine info' do
    example 'get_engine_info basic functionality' do
      expect(subject).to respond_to(:get_engine_info)
      expect(subject.get_engine_info).to be_a(Array)
    end

    example 'get_engine_info returns expected value' do
      engine = subject.get_engine_info.first
      expect(engine).to be_a(Crypt::GPGME::Engine)
      expect(engine.file_name).to be_a(String)
      expect(engine.version).to be_a(String)
      expect(engine.req_version).to be_a(String)
      expect(engine.home_dir).to be_a(String).or be_nil
    end
  end
end
