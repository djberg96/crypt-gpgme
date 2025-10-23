require 'spec_helper'
require 'tmpdir'

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

  context 'protocol' do
    example 'protocol basic functionality' do
      expect(subject).to respond_to(:protocol)
      expect(subject.protocol).to be_a(Integer)
    end

    example 'protocol optionally returns a string' do
      expect(subject.protocol(as: 'string')).to be_a(String)
    end

    example 'protocol returns expected value' do
      expect(subject.protocol).to eq(0)
      expect(subject.protocol(as: 'string')).to eq('OpenPGP')
    end

    example 'protocol= basic functionality' do
      expect(subject).to respond_to(:protocol=)
    end

    example 'protocol= works as expected' do
      expect(subject.protocol = 0).to eq(0)
    end
  end

  context 'include certs' do
    example 'include_certs basic functionality' do
      expect(subject).to respond_to(:include_certs)
      expect(subject.include_certs).to be_a(Integer)
    end

    example 'include_certs returns an expected value' do
      expect(subject.include_certs).to eq(Crypt::GPGME::GPGME_INCLUDE_CERTS_DEFAULT)
    end

    example 'include_certs= basic functionality' do
      expect(subject).to respond_to(:include_certs=)
    end

    example 'include_certs= works as expected' do
      expect(subject.include_certs = 1).to eq(1)
      expect(subject.include_certs).to eq(1)
    end
  end

  context 'keylist mode' do
    example 'keylist_mode basic functionality' do
      expect(subject).to respond_to(:keylist_mode)
      expect(subject.keylist_mode).to be_a(Integer)
    end

    example 'keylist_mode returns the expected result' do
      expect(subject.keylist_mode).to eq(Crypt::GPGME::GPGME_KEYLIST_MODE_LOCAL)
    end

    example 'keylist_mode accepts an optional argument to return a string or integer' do
      expect(subject.keylist_mode(as: 'string')).to eq('LOCAL')
      expect(subject.keylist_mode(as: 'integer')).to eq(Crypt::GPGME::GPGME_KEYLIST_MODE_LOCAL)
    end

    example 'keylist_mode= basic functionality' do
      expect(subject).to respond_to(:keylist_mode=)
    end

    example 'keylist_mode= works as expected' do
      current_mode = subject.keylist_mode
      expect(subject.keylist_mode = current_mode).to eq(current_mode)
    end
  end

  context 'set locale' do
    example 'set_locale basic functionality' do
      expect(subject).to respond_to(:set_locale)
    end

    example 'set_locale works as expected' do
      current_locale = ENV['LC_CTYPE'] || ENV['LANG']
      expect(subject.set_locale(Crypt::GPGME::LC_CTYPE, current_locale)).to eq({'LC_CTYPE' => current_locale})
    end
  end

  context 'set tofu policy' do
    let(:engine){ subject.get_engine_info.first }
    let(:userid){ 'bogus@bogus.com' }
    let(:flags) { Crypt::GPGME::GPGME_CREATE_NOPASSWD }
    let(:policy){ Crypt::GPGME::GPGME_TOFU_POLICY_AUTO }

    before do |example|
      subject.set_engine_info(engine.protocol, engine.file_name, example.metadata[:tmpdir])
      @key_result = subject.create_key(userid, flags: flags)
    end

    after do
      subject.delete_key(@key_result.fingerprint, force: true)
      subject.set_engine_info(engine.protocol, engine.file_name, engine.home_dir)
    end

    example 'set_tofu_policy basic functionality' do
      expect(subject).to respond_to(:set_tofu_policy)
    end

    example 'set_tofu_policy works as expected' do
      key = subject.get_key(@key_result.fingerprint)
      expect(subject.set_tofu_policy(key, policy)).to be(policy)
    end
  end

  context 'offline' do
    example 'offline? basic functionality' do
      expect(subject).to respond_to(:offline?)
      expect(subject.offline?).to be_boolean
    end

    example 'offline= basic functionality' do
      expect(subject).to respond_to(:offline=)
    end

    example 'offline= works as expected' do
      current = subject.offline?
      expect(subject.offline = (!current)).to eq(!current)
      expect(subject.offline = current).to eq(current)
    end
  end

  context 'pinentry mode' do
    example 'pinentry_mode basic functionality' do
      expect(subject).to respond_to(:pinentry_mode)
      expect(subject.pinentry_mode).to be_a(Integer)
    end

    example 'pinentry_mode returns expected value' do
      expect(subject.pinentry_mode).to eq(Crypt::GPGME::GPGME_PINENTRY_MODE_DEFAULT)
    end

    example 'pinentry_mode accepts an optional argument' do
      expect(subject.pinentry_mode(as: 'integer')).to eq(Crypt::GPGME::GPGME_PINENTRY_MODE_DEFAULT)
      expect(subject.pinentry_mode(as: 'string')).to eq('default')
    end

    example 'pinentry_mode= basic functionality' do
      expect(subject).to respond_to(:pinentry_mode=)
    end

    example 'pinentry_mode= works as expected' do
      current_mode = subject.pinentry_mode
      expect(subject.pinentry_mode = current_mode).to eq(current_mode)
    end
  end

  context 'create key', :tempfs do
    let(:engine){ subject.get_engine_info.first }
    let(:userid){ 'bogus@bogus.com' }
    let(:flags) { Crypt::GPGME::GPGME_CREATE_NOPASSWD }

    before do |example|
      subject.set_engine_info(engine.protocol, engine.file_name, example.metadata[:tmpdir])
      @result = nil
    end

    after do |example|
      if @result
        key = subject.get_key(@result.fingerprint)
        subject.delete_key(key, force: true)
      end
      subject.set_engine_info(engine.protocol, engine.file_name, engine.home_dir)
    end

    example 'create_key basic functionality' do
      expect(subject).to respond_to(:create_key)
    end

    example 'create_key works as expected' do
      size = subject.list_keys.size
      @result = subject.create_key(userid, flags: flags)
      expect(@result).to be_a(Crypt::GPGME::GenkeyResult)
      expect(subject.list_keys.size).to eq(size + 1)
    end

    example 'create_key return value has expected result' do
      @result = subject.create_key('bogus2@bogus.com', flags: flags)
      expect(@result.fingerprint).to be_a(String)
    end
  end

  context 'get key', :tempfs do
    let(:engine){ subject.get_engine_info.first }
    let(:userid){ 'bogus@bogus.com' }
    let(:create_flags) { Crypt::GPGME::GPGME_CREATE_NOPASSWD }
    let(:delete_flags) { Crypt::GPGME::GPGME_DELETE_ALLOW_SECRET | Crypt::GPGME::GPGME_DELETE_FORCE }

    before do |example|
      subject.set_engine_info(engine.protocol, engine.file_name, example.metadata[:tmpdir])
      @key_result = subject.create_key(userid, flags: create_flags)
    end

    after do
      subject.delete_key(@key_result.fingerprint, force: true)
      subject.set_engine_info(engine.protocol, engine.file_name, engine.home_dir)
    end

    example 'get_key basic functionality' do
      expect(subject).to respond_to(:get_key)
    end

    example 'get_key returns the expected value' do
      key = subject.get_key(@key_result.fingerprint)
      expect(key).to be_a(Crypt::GPGME::Key)
      expect(key.fingerprint).to eq(@key_result.fingerprint)
    end

    example 'get_key accepts an optional argument to get the secret key' do
      key = subject.get_key(@key_result.fingerprint, false)
      expect(key).to be_a(Crypt::GPGME::Key)
      expect(key.fingerprint).to eq(@key_result.fingerprint)
    end
  end

  context 'delete key', :tempfs do
    let(:engine){ subject.get_engine_info.first }
    let(:userid){ 'bogus@bogus.com' }
    let(:create_flags) { Crypt::GPGME::GPGME_CREATE_NOPASSWD }
    let(:delete_flags) { Crypt::GPGME::GPGME_DELETE_ALLOW_SECRET | Crypt::GPGME::GPGME_DELETE_FORCE }

    before do |example|
      subject.set_engine_info(engine.protocol, engine.file_name, example.metadata[:tmpdir])
    end

    after do
      subject.set_engine_info(engine.protocol, engine.file_name, engine.home_dir)
    end

    example 'delete_key basic functionality' do
      expect(subject).to respond_to(:delete_key)
    end

    example 'delete_key works as expected with a string argument' do
      subject.create_key(userid, flags: create_flags)
      size = subject.list_keys.size

      expect(subject.delete_key(userid, force: true)).to be(true)
      expect(subject.list_keys.size).to eq(size - 1)
    end

    example 'delete_key works as expected with a key argument' do
      subject.create_key(userid, flags: create_flags)
      key_object = subject.list_keys(pattern: userid).first
      size = subject.list_keys.size

      expect(subject.delete_key(key_object, force: true)).to be(true)
      expect(subject.list_keys.size).to eq(size - 1)
    end
  end
end
