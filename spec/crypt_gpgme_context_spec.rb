require 'rspec'
require 'rspec_boolean'
require 'crypt/gpgme'

RSpec.describe Crypt::GPGME::Context do
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
