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

  context 'create key' do
    let(:engine){ subject.get_engine_info.first }
    let(:tmpdir){ Dir.mktmpdir }
    let(:userid){ 'bogus@bogus.com' }
    let(:flags) { Crypt::GPGME::GPGME_CREATE_NOPASSWD }

    before do
      # Create directories with proper permissions
      FileUtils.mkdir_p(tmpdir, mode: 0700)
      FileUtils.mkdir_p(File.join(tmpdir, 'private-keys-v1.d'), mode: 0700)
      FileUtils.mkdir_p(File.join(tmpdir, 'openpgp-revocs.d'), mode: 0700)
      FileUtils.mkdir_p(File.join(tmpdir, 'public-keys.d'), mode: 0755)

      # Create required files with proper permissions
      FileUtils.touch(File.join(tmpdir, 'pubring.kbx'))
      FileUtils.touch(File.join(tmpdir, 'trustdb.gpg'))
      FileUtils.touch(File.join(tmpdir, 'sshcontrol'))
      FileUtils.touch(File.join(tmpdir, 'common.conf'))

      # Set permissions
      File.chmod(0600, File.join(tmpdir, 'trustdb.gpg'))
      File.chmod(0644, File.join(tmpdir, 'common.conf'))
      File.chmod(0600, File.join(tmpdir, 'sshcontrol'))

      @original_home = ENV['GNUPGHOME']
      ENV['GNUPGHOME'] = tmpdir

      @size = subject.list_keys.size
      subject.set_engine_info(engine.protocol, engine.file_name, tmpdir)
    end

    after do
      ENV['GNUPGHOME'] = @original_home
      subject.set_engine_info(engine.protocol, engine.file_name, engine.home_dir)
      FileUtils.remove_entry_secure(tmpdir) if File.directory?(tmpdir)
    end

    example 'create_key basic functionality' do
      expect(subject).to respond_to(:create_key)
    end

    example 'create_key works as expected' do
      subject.pinentry_mode = Crypt::GPGME::GPGME_PINENTRY_MODE_LOOPBACK
      expect(subject.create_key(userid, flags: flags)).to be_a(Crypt::GPGME::Structs::GenkeyResult)
      expect(subject.list_keys.size).to eq(@size + 1)
    end
  end
end
