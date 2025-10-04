#######################################################################
# context_spec.rb
#
# Specs for the Crypt::GPGME::Context class.
#######################################################################
require 'spec_helper'

RSpec.describe Crypt::GPGME::Context do
  subject { described_class.new }

  after do
    subject.release
  end

  describe '#armor?' do
    example 'basic functionality' do
      expect(subject).to respond_to(:armor?)
    end

    example 'returns a boolean' do
      expect(subject.armor?).to be_boolean
    end

    example 'returns false by default' do
      expect(subject.armor?).to be(false)
    end
  end

  describe '#armor=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:armor=)
    end

    example 'returns a boolean' do
      expect(subject.armor = true).to be_boolean
    end

    example 'sets the armor mode' do
      expect(subject.armor?).to be(false)
      subject.armor = true
      expect(subject.armor?).to be(true)
    end

    example 'can toggle armor mode' do
      subject.armor = true
      expect(subject.armor?).to be(true)
      subject.armor = false
      expect(subject.armor?).to be(false)
    end
  end

  describe '#get_flag' do
    example 'basic functionality' do
      expect(subject).to respond_to(:get_flag)
    end
  end

  describe '#set_flag' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_flag)
    end
  end

  describe '#get_engine_info' do
    example 'basic functionality' do
      expect(subject).to respond_to(:get_engine_info)
    end

    example 'returns an array' do
      expect(subject.get_engine_info).to be_an(Array)
    end

    example 'returns engine information with expected keys' do
      info = subject.get_engine_info
      expect(info).not_to be_empty
      expect(info.first).to have_key(:protocol)
      expect(info.first).to have_key(:file_name)
      expect(info.first).to have_key(:version)
    end
  end

  describe '#get_key' do
    example 'basic functionality' do
      expect(subject).to respond_to(:get_key)
    end
  end

  describe '#set_engine_info' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_engine_info)
    end
  end

  describe '#include_certs' do
    example 'basic functionality' do
      expect(subject).to respond_to(:include_certs)
    end

    example 'returns an integer' do
      expect(subject.include_certs).to be_an(Integer)
    end
  end

  describe '#include_certs=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:include_certs=)
    end
  end

  describe '#keylist_mode' do
    example 'basic functionality' do
      expect(subject).to respond_to(:keylist_mode)
    end

    example 'returns an integer by default' do
      expect(subject.keylist_mode).to be_an(Integer)
    end

    example 'returns a string when human_readable is true' do
      expect(subject.keylist_mode(human_readable: true)).to be_a(String)
    end

    example 'returns LOCAL by default' do
      expect(subject.keylist_mode(human_readable: true)).to eq('LOCAL')
    end
  end

  describe '#keylist_mode=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:keylist_mode=)
    end

    example 'sets the keylist mode' do
      mode = Crypt::GPGME::Constants::GPGME_KEYLIST_MODE_LOCAL |
             Crypt::GPGME::Constants::GPGME_KEYLIST_MODE_SIGS
      subject.keylist_mode = mode
      expect(subject.keylist_mode).to eq(mode)
    end
  end

  describe '#set_locale' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_locale)
    end
  end

  describe '#set_tofu_policy' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_tofu_policy)
    end
  end

  describe '#protocol' do
    example 'basic functionality' do
      expect(subject).to respond_to(:protocol)
    end

    example 'returns an integer' do
      expect(subject.protocol).to be_an(Integer)
    end
  end

  describe '#protocol=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:protocol=)
    end
  end

  describe '#offline?' do
    example 'basic functionality' do
      expect(subject).to respond_to(:offline?)
    end

    example 'returns a boolean' do
      expect(subject.offline?).to be_boolean
    end
  end

  describe '#offline=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:offline=)
    end

    example 'sets the offline mode' do
      subject.offline = true
      expect(subject.offline?).to be(true)
    end
  end

  describe '#pinentry_mode' do
    example 'basic functionality' do
      expect(subject).to respond_to(:pinentry_mode)
    end

    example 'returns an integer' do
      expect(subject.pinentry_mode).to be_an(Integer)
    end
  end

  describe '#pinentry_mode=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:pinentry_mode=)
    end
  end

  describe '#sign' do
    example 'basic functionality' do
      expect(subject).to respond_to(:sign)
    end
  end

  describe '#text_mode?' do
    example 'basic functionality' do
      expect(subject).to respond_to(:text_mode?)
    end

    example 'returns a boolean' do
      expect(subject.text_mode?).to be_boolean
    end
  end

  describe '#text_mode=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:text_mode=)
    end

    example 'sets the text mode' do
      subject.text_mode = true
      expect(subject.text_mode?).to be(true)
    end
  end

  describe '#release' do
    example 'basic functionality' do
      expect(subject).to respond_to(:release)
    end

    example 'can be called without error' do
      expect { subject.release }.not_to raise_error
    end
  end

  describe '#list_keys' do
    example 'basic functionality' do
      expect(subject).to respond_to(:list_keys)
    end

    example 'returns an array' do
      expect(subject.list_keys).to be_an(Array)
    end

    example 'accepts a pattern argument' do
      expect { subject.list_keys("test") }.not_to raise_error
    end

    example 'accepts a secret argument' do
      expect { subject.list_keys(nil, 1) }.not_to raise_error
    end
  end
end
