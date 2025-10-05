#######################################################################
# context_spec.rb
#
# Specs for the Crypt::GPGME::Context class.
#######################################################################
require 'spec_helper'

RSpec.describe Crypt::GPGME::Context do
  subject { described_class.new }

  after do
    subject.release unless subject.released?
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

  describe '#sender' do
    example 'basic functionality' do
      expect(subject).to respond_to(:sender)
    end

    example 'returns nil by default' do
      expect(subject.sender).to be_nil
    end

    example 'returns a string when set' do
      subject.sender = "test@example.com"
      expect(subject.sender).to be_a(String)
    end

    example 'returns the sender address that was set' do
      address = "alice@example.com"
      subject.sender = address
      expect(subject.sender).to eq(address)
    end
  end

  describe '#sender=' do
    example 'basic functionality' do
      expect(subject).to respond_to(:sender=)
    end

    example 'accepts a simple email address' do
      expect { subject.sender = "alice@example.com" }.not_to raise_error
    end

    example 'accepts an email with display name' do
      expect { subject.sender = "Alice <alice@example.com>" }.not_to raise_error
    end

    example 'normalizes email with display name to just the address' do
      subject.sender = "Alice <alice@example.com>"
      expect(subject.sender).to eq("alice@example.com")
    end

    example 'returns the address that was set' do
      address = "bob@example.com"
      result = subject.sender = address
      expect(result).to eq(address)
    end

    example 'sets the sender that can be retrieved' do
      subject.sender = "charlie@example.com"
      expect(subject.sender).to eq("charlie@example.com")
    end

    example 'can update the sender' do
      subject.sender = "first@example.com"
      expect(subject.sender).to eq("first@example.com")
      subject.sender = "second@example.com"
      expect(subject.sender).to eq("second@example.com")
    end
  end

  describe '#set_progress_callback' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_progress_callback)
    end

    example 'accepts a proc' do
      callback = Proc.new { |what, type, current, total| }
      expect { subject.set_progress_callback(callback) }.not_to raise_error
    end

    example 'accepts a block' do
      expect do
        subject.set_progress_callback do |what, type, current, total|
          # Progress handling
        end
      end.not_to raise_error
    end

    example 'accepts nil to clear callback' do
      subject.set_progress_callback { |what, type, current, total| }
      expect { subject.set_progress_callback(nil) }.not_to raise_error
    end

    example 'returns the callback that was set' do
      callback = Proc.new { |what, type, current, total| }
      result = subject.set_progress_callback(callback)
      expect(result).to eq(callback)
    end

    example 'returns nil when clearing callback' do
      subject.set_progress_callback { |what, type, current, total| }
      result = subject.set_progress_callback(nil)
      expect(result).to be_nil
    end

    example 'stores the callback for later retrieval' do
      callback = Proc.new { |what, type, current, total| }
      subject.set_progress_callback(callback)
      expect(subject.progress_callback).to eq(callback)
    end

    example 'clears the stored callback when set to nil' do
      subject.set_progress_callback { |what, type, current, total| }
      subject.set_progress_callback(nil)
      expect(subject.progress_callback).to be_nil
    end

    example 'can update the callback' do
      callback1 = Proc.new { |what, type, current, total| puts "First" }
      callback2 = Proc.new { |what, type, current, total| puts "Second" }

      subject.set_progress_callback(callback1)
      expect(subject.progress_callback).to eq(callback1)

      subject.set_progress_callback(callback2)
      expect(subject.progress_callback).to eq(callback2)
    end
  end

  describe '#progress_callback' do
    example 'basic functionality' do
      expect(subject).to respond_to(:progress_callback)
    end

    example 'returns nil by default' do
      expect(subject.progress_callback).to be_nil
    end

    example 'returns the callback that was set' do
      callback = Proc.new { |what, type, current, total| }
      subject.set_progress_callback(callback)
      expect(subject.progress_callback).to eq(callback)
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

  describe '#released?' do
    example 'basic functionality' do
      expect(subject).to respond_to(:released?)
    end

    example 'returns a boolean' do
      expect(subject.released?).to be_boolean
    end

    example 'returns false for a new context' do
      expect(subject.released?).to be(false)
    end

    example 'returns true after release is called' do
      expect(subject.released?).to be(false)
      subject.release
      expect(subject.released?).to be(true)
    end
  end

  describe '#release' do
    example 'basic functionality' do
      expect(subject).to respond_to(:release)
    end

    example 'can be called without error' do
      expect { subject.release }.not_to raise_error
    end

    example 'sets released? to true' do
      subject.release
      expect(subject.released?).to be(true)
    end

    example 'can be called multiple times safely' do
      subject.release
      expect { subject.release }.not_to raise_error
      expect { subject.release }.not_to raise_error
    end
  end

  describe '#set_status_callback' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_status_callback)
    end

    example 'accepts a Proc argument' do
      callback = Proc.new { |keyword, args| 0 }
      expect { subject.set_status_callback(callback) }.not_to raise_error
    end

    example 'accepts a block' do
      expect { subject.set_status_callback { |keyword, args| 0 } }.not_to raise_error
    end

    example 'accepts nil to clear the callback' do
      subject.set_status_callback { |keyword, args| 0 }
      expect { subject.set_status_callback(nil) }.not_to raise_error
    end

    example 'returns the callback that was set' do
      callback = Proc.new { |keyword, args| 0 }
      result = subject.set_status_callback(callback)
      expect(result).to eq(callback)
    end

    example 'returns nil when cleared' do
      result = subject.set_status_callback(nil)
      expect(result).to be_nil
    end

    example 'stores the callback' do
      callback = Proc.new { |keyword, args| 0 }
      subject.set_status_callback(callback)
      expect(subject.status_callback).to eq(callback)
    end

    example 'clears the stored callback when set to nil' do
      subject.set_status_callback { |keyword, args| 0 }
      subject.set_status_callback(nil)
      expect(subject.status_callback).to be_nil
    end

    example 'overwrites previous callback' do
      callback1 = Proc.new { |keyword, args| 0 }
      callback2 = Proc.new { |keyword, args| 1 }
      subject.set_status_callback(callback1)
      subject.set_status_callback(callback2)
      expect(subject.status_callback).to eq(callback2)
    end

    example 'block takes precedence over proc argument' do
      callback = Proc.new { |keyword, args| 0 }
      result = subject.set_status_callback(callback) { |keyword, args| 1 }
      expect(result).not_to eq(callback)
      expect(result).to be_a(Proc)
    end
  end

  describe '#status_callback' do
    example 'basic functionality' do
      expect(subject).to respond_to(:status_callback)
    end

    example 'returns nil by default' do
      expect(subject.status_callback).to be_nil
    end

    example 'returns the callback that was set' do
      callback = Proc.new { |keyword, args| 0 }
      subject.set_status_callback(callback)
      expect(subject.status_callback).to eq(callback)
    end

    example 'returns nil after callback is cleared' do
      subject.set_status_callback { |keyword, args| 0 }
      subject.set_status_callback(nil)
      expect(subject.status_callback).to be_nil
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
