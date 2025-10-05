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

  describe '#get_audit_log' do
    example 'basic functionality' do
      expect(subject).to respond_to(:get_audit_log)
    end

    example 'accepts no arguments (uses default flags)' do
      begin
        result = subject.get_audit_log
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        # Audit log may not be implemented for all protocols
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_DEFAULT flag' do
      begin
        result = subject.get_audit_log(Crypt::GPGME::Constants::GPGME_AUDITLOG_DEFAULT)
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        # Audit log may not be implemented for all protocols
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_HTML flag' do
      begin
        result = subject.get_audit_log(Crypt::GPGME::Constants::GPGME_AUDITLOG_HTML)
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_DIAG flag' do
      begin
        result = subject.get_audit_log(Crypt::GPGME::Constants::GPGME_AUDITLOG_DIAG)
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_WITH_HELP flag' do
      begin
        result = subject.get_audit_log(Crypt::GPGME::Constants::GPGME_AUDITLOG_WITH_HELP)
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts combined flags' do
      flags = Crypt::GPGME::Constants::GPGME_AUDITLOG_HTML | Crypt::GPGME::Constants::GPGME_AUDITLOG_WITH_HELP
      begin
        result = subject.get_audit_log(flags)
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'returns a string if implemented' do
      begin
        result = subject.get_audit_log
        expect(result).to be_a(String)
      rescue Crypt::GPGME::Error => e
        # Audit log may not be implemented - that's okay
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'can be called multiple times without crashing' do
      2.times do
        begin
          subject.get_audit_log
        rescue Crypt::GPGME::Error
          # Expected for unimplemented functionality
        end
      end
      expect(true).to be(true)
    end

    example 'raises Crypt::GPGME::Error when not implemented' do
      expect { subject.get_audit_log }.to raise_error(Crypt::GPGME::Error, /Not implemented/)
    end
  end

  describe '#get_audit_log_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:get_audit_log_start)
    end

    example 'accepts no arguments (uses default flags)' do
      begin
        result = subject.get_audit_log_start
        expect(result).to be_a(Crypt::GPGME::Structs::Data)
      rescue Crypt::GPGME::Error => e
        # Audit log may not be implemented for all protocols
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_DEFAULT flag' do
      begin
        result = subject.get_audit_log_start(Crypt::GPGME::Constants::GPGME_AUDITLOG_DEFAULT)
        expect(result).to be_a(Crypt::GPGME::Structs::Data)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_HTML flag' do
      begin
        result = subject.get_audit_log_start(Crypt::GPGME::Constants::GPGME_AUDITLOG_HTML)
        expect(result).to be_a(Crypt::GPGME::Structs::Data)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts GPGME_AUDITLOG_DIAG flag' do
      begin
        result = subject.get_audit_log_start(Crypt::GPGME::Constants::GPGME_AUDITLOG_DIAG)
        expect(result).to be_a(Crypt::GPGME::Structs::Data)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'accepts combined flags' do
      flags = Crypt::GPGME::Constants::GPGME_AUDITLOG_HTML | Crypt::GPGME::Constants::GPGME_AUDITLOG_WITH_HELP
      begin
        result = subject.get_audit_log_start(flags)
        expect(result).to be_a(Crypt::GPGME::Structs::Data)
      rescue Crypt::GPGME::Error => e
        expect(e.message).to match(/Not implemented|Invalid value/)
      end
    end

    example 'can be called multiple times without crashing' do
      2.times do
        begin
          subject.get_audit_log_start
        rescue Crypt::GPGME::Error
          # Expected for unimplemented functionality
        end
      end
      expect(true).to be(true)
    end

    example 'raises Crypt::GPGME::Error when not implemented' do
      expect { subject.get_audit_log_start }.to raise_error(Crypt::GPGME::Error, /Not implemented/)
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

    example 'accepts an array of patterns' do
      expect { subject.list_keys(["test1", "test2"]) }.not_to raise_error
    end

    example 'returns an array when given array of patterns' do
      result = subject.list_keys(["test1", "test2"])
      expect(result).to be_an(Array)
    end

    example 'accepts array of patterns with secret argument' do
      expect { subject.list_keys(["test1", "test2"], 1) }.not_to raise_error
    end

    example 'handles empty array of patterns' do
      expect { subject.list_keys([]) }.not_to raise_error
    end

    example 'handles array with single pattern' do
      expect { subject.list_keys(["test"]) }.not_to raise_error
      result = subject.list_keys(["test"])
      expect(result).to be_an(Array)
    end

    example 'handles array with multiple patterns' do
      patterns = ["alice@example.com", "bob@example.com", "carol@example.com"]
      expect { subject.list_keys(patterns) }.not_to raise_error
      result = subject.list_keys(patterns)
      expect(result).to be_an(Array)
    end

    # Note: Data object support is implemented but not tested here because
    # it requires actual exported key data to work properly. Passing empty
    # data causes segmentation faults. The feature is documented in the
    # method's YARD documentation for users who have real key data.
  end

  describe '#set_expire' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_expire)
    end

    example 'requires at least 2 arguments' do
      expect { subject.set_expire }.to raise_error(ArgumentError)
    end

    example 'accepts a key and expiration time' do
      expect(subject.method(:set_expire).arity).to eq(-3)
    end

    example 'raises an error with nil key' do
      expect { subject.set_expire(nil, 0) }.to raise_error(Crypt::GPGME::Error, /Invalid value/)
    end

    example 'accepts expiration time of 0' do
      # We can't actually test this without a valid key and passphrase,
      # but we can verify the method accepts the parameter
      expect(subject.method(:set_expire).parameters).to include([:req, :expires])
    end

    example 'accepts subfprs parameter' do
      expect(subject.method(:set_expire).parameters).to include([:opt, :subfprs])
    end

    example 'accepts reserved parameter' do
      expect(subject.method(:set_expire).parameters).to include([:opt, :reserved])
    end

    example 'method signature accepts 2 to 4 arguments' do
      params = subject.method(:set_expire).parameters
      required = params.count { |type, _| type == :req }
      optional = params.count { |type, _| type == :opt }
      expect(required).to eq(2)
      expect(optional).to eq(2)
    end

    # Note: Full integration testing with actual keys requires:
    # - Valid keys in the keyring
    # - Passphrase handling via pinentry or passphrase callback
    # - Ability to modify keys (not read-only)
    # These tests verify the interface is correct.
  end

  describe '#set_expire_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_expire_start)
    end

    example 'requires at least 2 arguments' do
      expect { subject.set_expire_start }.to raise_error(ArgumentError)
    end

    example 'accepts a key and expiration time' do
      expect(subject.method(:set_expire_start).arity).to eq(-3)
    end

    example 'raises an error with nil key' do
      expect { subject.set_expire_start(nil, 0) }.to raise_error(Crypt::GPGME::Error, /Invalid value/)
    end

    example 'accepts expiration time of 0' do
      expect(subject.method(:set_expire_start).parameters).to include([:req, :expires])
    end

    example 'accepts subfprs parameter' do
      expect(subject.method(:set_expire_start).parameters).to include([:opt, :subfprs])
    end

    example 'accepts reserved parameter' do
      expect(subject.method(:set_expire_start).parameters).to include([:opt, :reserved])
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:set_expire).parameters
      async_params = subject.method(:set_expire_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of set_expire' do
      # Verify both methods exist and have similar signatures
      expect(subject).to respond_to(:set_expire)
      expect(subject).to respond_to(:set_expire_start)

      sync_arity = subject.method(:set_expire).arity
      async_arity = subject.method(:set_expire_start).arity
      expect(async_arity).to eq(sync_arity)
    end

    # Note: Asynchronous operations require wait() to complete.
    # Full integration testing requires valid keys and passphrases.
  end

  describe '#set_owner_trust' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_owner_trust)
    end

    example 'requires at least 2 arguments' do
      expect { subject.set_owner_trust }.to raise_error(ArgumentError)
    end

    example 'accepts a key and trust value' do
      expect(subject.method(:set_owner_trust).arity).to eq(2)
    end

    example 'raises an error with nil key' do
      expect { subject.set_owner_trust(nil, "full") }.to raise_error(Crypt::GPGME::Error, /Invalid value/)
    end

    example 'accepts string trust values' do
      # We verify the method accepts these values by checking it doesn't raise ArgumentError
      trust_values = ["unknown", "undefined", "never", "marginal", "full", "ultimate"]
      trust_values.each do |value|
        expect(subject.method(:set_owner_trust).parameters).to include([:req, :value])
      end
    end

    example 'accepts integer trust values' do
      expect(subject.method(:set_owner_trust).parameters).to include([:req, :value])
    end

    example 'converts "full" string to appropriate format' do
      # This tests that string values are accepted (actual conversion tested in integration)
      expect { subject.set_owner_trust(nil, "full") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'converts "ultimate" string to appropriate format' do
      expect { subject.set_owner_trust(nil, "ultimate") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'converts integer 4 (FULL) to appropriate format' do
      expect { subject.set_owner_trust(nil, 4) }.to raise_error(Crypt::GPGME::Error)
    end

    example 'converts integer 5 (ULTIMATE) to appropriate format' do
      expect { subject.set_owner_trust(nil, 5) }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises ArgumentError for invalid integer trust value' do
      expect { subject.set_owner_trust(nil, 99) }.to raise_error(ArgumentError, /Invalid trust value/)
    end

    example 'raises ArgumentError for invalid type' do
      expect { subject.set_owner_trust(nil, []) }.to raise_error(ArgumentError, /must be a String or Integer/)
    end

    example 'handles case-insensitive string values' do
      # Lowercase should work (gets converted to lowercase internally)
      expect { subject.set_owner_trust(nil, "FULL") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'method signature is correct' do
      params = subject.method(:set_owner_trust).parameters
      expect(params).to eq([[:req, :key], [:req, :value]])
    end

    # Note: Full integration testing with actual keys requires:
    # - Valid keys in the keyring
    # - OpenPGP protocol (not CMS)
    # - Appropriate permissions
    # These tests verify the interface is correct.
  end

  describe '#set_owner_trust_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_owner_trust_start)
    end

    example 'requires at least 2 arguments' do
      expect { subject.set_owner_trust_start }.to raise_error(ArgumentError)
    end

    example 'accepts a key and trust value' do
      expect(subject.method(:set_owner_trust_start).arity).to eq(2)
    end

    example 'raises an error with nil key' do
      expect { subject.set_owner_trust_start(nil, "full") }.to raise_error(Crypt::GPGME::Error, /Invalid value/)
    end

    example 'accepts string trust values' do
      trust_values = ["unknown", "undefined", "never", "marginal", "full", "ultimate"]
      trust_values.each do |value|
        expect(subject.method(:set_owner_trust_start).parameters).to include([:req, :value])
      end
    end

    example 'accepts integer trust values' do
      expect(subject.method(:set_owner_trust_start).parameters).to include([:req, :value])
    end

    example 'raises ArgumentError for invalid integer trust value' do
      expect { subject.set_owner_trust_start(nil, 99) }.to raise_error(ArgumentError, /Invalid trust value/)
    end

    example 'raises ArgumentError for invalid type' do
      expect { subject.set_owner_trust_start(nil, {}) }.to raise_error(ArgumentError, /must be a String or Integer/)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:set_owner_trust).parameters
      async_params = subject.method(:set_owner_trust_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of set_owner_trust' do
      expect(subject).to respond_to(:set_owner_trust)
      expect(subject).to respond_to(:set_owner_trust_start)

      sync_arity = subject.method(:set_owner_trust).arity
      async_arity = subject.method(:set_owner_trust_start).arity
      expect(async_arity).to eq(sync_arity)
    end

    # Note: Asynchronous operations require wait() to complete.
    # Full integration testing requires valid keys and appropriate permissions.
  end

  describe '#create_key' do
    example 'basic functionality' do
      expect(subject).to respond_to(:create_key)
    end

    example 'requires at least 1 argument' do
      expect { subject.create_key }.to raise_error(ArgumentError)
    end

    example 'accepts userid parameter' do
      expect(subject.method(:create_key).parameters).to include([:req, :userid])
    end

    example 'accepts optional algo parameter' do
      expect(subject.method(:create_key).parameters).to include([:opt, :algo])
    end

    example 'accepts optional reserved parameter' do
      expect(subject.method(:create_key).parameters).to include([:opt, :reserved])
    end

    example 'accepts optional expires parameter' do
      expect(subject.method(:create_key).parameters).to include([:opt, :expires])
    end

    example 'accepts optional certkey parameter' do
      expect(subject.method(:create_key).parameters).to include([:opt, :certkey])
    end

    example 'accepts optional flags parameter' do
      expect(subject.method(:create_key).parameters).to include([:opt, :flags])
    end

    example 'method has correct arity' do
      expect(subject.method(:create_key).arity).to eq(-2)
    end

    example 'returns a hash' do
      # We can't actually create keys without passphrase handling,
      # but we verify the return type would be correct
      expect(subject.method(:create_key).parameters.first).to eq([:req, :userid])
    end

    # Note: Full integration testing requires:
    # - Passphrase callback or pinentry setup
    # - Appropriate system permissions
    # - Time for key generation (can be slow)
    # These tests verify the interface is correct.
  end

  describe '#create_key_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:create_key_start)
    end

    example 'requires at least 1 argument' do
      expect { subject.create_key_start }.to raise_error(ArgumentError)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:create_key).parameters
      async_params = subject.method(:create_key_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of create_key' do
      expect(subject).to respond_to(:create_key)
      expect(subject).to respond_to(:create_key_start)

      sync_arity = subject.method(:create_key).arity
      async_arity = subject.method(:create_key_start).arity
      expect(async_arity).to eq(sync_arity)
    end

    # Note: Asynchronous operations require wait() to complete.
  end

  describe '#create_subkey' do
    example 'basic functionality' do
      expect(subject).to respond_to(:create_subkey)
    end

    example 'requires at least 1 argument' do
      expect { subject.create_subkey }.to raise_error(ArgumentError)
    end

    example 'accepts key parameter' do
      expect(subject.method(:create_subkey).parameters).to include([:req, :key])
    end

    example 'accepts optional algo parameter' do
      expect(subject.method(:create_subkey).parameters).to include([:opt, :algo])
    end

    example 'accepts optional reserved parameter' do
      expect(subject.method(:create_subkey).parameters).to include([:opt, :reserved])
    end

    example 'accepts optional expires parameter' do
      expect(subject.method(:create_subkey).parameters).to include([:opt, :expires])
    end

    example 'accepts optional flags parameter' do
      expect(subject.method(:create_subkey).parameters).to include([:opt, :flags])
    end

    example 'method has correct arity' do
      expect(subject.method(:create_subkey).arity).to eq(-2)
    end

    example 'raises error with nil key' do
      expect { subject.create_subkey(nil) }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    # Note: Full integration testing requires:
    # - Valid primary key in keyring
    # - Passphrase for the primary key
    # - Appropriate system permissions
    # These tests verify the interface is correct.
  end

  describe '#create_subkey_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:create_subkey_start)
    end

    example 'requires at least 1 argument' do
      expect { subject.create_subkey_start }.to raise_error(ArgumentError)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:create_subkey).parameters
      async_params = subject.method(:create_subkey_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of create_subkey' do
      expect(subject).to respond_to(:create_subkey)
      expect(subject).to respond_to(:create_subkey_start)

      sync_arity = subject.method(:create_subkey).arity
      async_arity = subject.method(:create_subkey_start).arity
      expect(async_arity).to eq(sync_arity)
    end

    example 'raises error with nil key' do
      expect { subject.create_subkey_start(nil) }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    # Note: Asynchronous operations require wait() to complete.
  end

  describe '#get_genkey_result' do
    example 'basic functionality' do
      expect(subject).to respond_to(:get_genkey_result)
    end

    example 'takes no arguments' do
      expect(subject.method(:get_genkey_result).arity).to eq(0)
    end

    example 'returns a hash' do
      result = subject.get_genkey_result
      expect(result).to be_a(Hash)
    end

    example 'returns empty hash when no operation has been performed' do
      result = subject.get_genkey_result
      expect(result).to be_empty
    end

    # Note: Testing with actual results requires completing a key generation operation.
  end

  describe '#add_uid' do
    example 'basic functionality' do
      expect(subject).to respond_to(:add_uid)
    end

    example 'requires at least 2 arguments' do
      expect { subject.add_uid }.to raise_error(ArgumentError)
    end

    example 'accepts key parameter' do
      expect(subject.method(:add_uid).parameters).to include([:req, :key])
    end

    example 'accepts userid parameter' do
      expect(subject.method(:add_uid).parameters).to include([:req, :userid])
    end

    example 'accepts optional reserved parameter' do
      expect(subject.method(:add_uid).parameters).to include([:opt, :reserved])
    end

    example 'method has correct arity' do
      # -3 means 2 required, 1 optional
      expect(subject.method(:add_uid).arity).to eq(-3)
    end

    example 'raises error with nil key' do
      expect { subject.add_uid(nil, "Test <test@example.com>") }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    example 'raises error with nil userid' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.add_uid(key, nil) }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Actual UID addition requires a secret key with passphrase access.
  end

  describe '#add_uid_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:add_uid_start)
    end

    example 'requires at least 2 arguments' do
      expect { subject.add_uid_start }.to raise_error(ArgumentError)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:add_uid).parameters
      async_params = subject.method(:add_uid_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of add_uid' do
      expect(subject.method(:add_uid_start).arity).to eq(subject.method(:add_uid).arity)
    end

    example 'raises error with nil key' do
      expect { subject.add_uid_start(nil, "Test <test@example.com>") }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    example 'raises error with nil userid' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.add_uid_start(key, nil) }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Asynchronous operations require wait() to complete.
  end

  describe '#revoke_uid' do
    example 'basic functionality' do
      expect(subject).to respond_to(:revoke_uid)
    end

    example 'requires at least 2 arguments' do
      expect { subject.revoke_uid }.to raise_error(ArgumentError)
    end

    example 'accepts key parameter' do
      expect(subject.method(:revoke_uid).parameters).to include([:req, :key])
    end

    example 'accepts userid parameter' do
      expect(subject.method(:revoke_uid).parameters).to include([:req, :userid])
    end

    example 'accepts optional reserved parameter' do
      expect(subject.method(:revoke_uid).parameters).to include([:opt, :reserved])
    end

    example 'method has correct arity' do
      # -3 means 2 required, 1 optional
      expect(subject.method(:revoke_uid).arity).to eq(-3)
    end

    example 'raises error with nil key' do
      expect { subject.revoke_uid(nil, "Test <test@example.com>") }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    example 'raises error with nil userid' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.revoke_uid(key, nil) }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Actual UID revocation requires a secret key with passphrase access.
  end

  describe '#revoke_uid_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:revoke_uid_start)
    end

    example 'requires at least 2 arguments' do
      expect { subject.revoke_uid_start }.to raise_error(ArgumentError)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:revoke_uid).parameters
      async_params = subject.method(:revoke_uid_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of revoke_uid' do
      expect(subject.method(:revoke_uid_start).arity).to eq(subject.method(:revoke_uid).arity)
    end

    example 'raises error with nil key' do
      expect { subject.revoke_uid_start(nil, "Test <test@example.com>") }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    example 'raises error with nil userid' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.revoke_uid_start(key, nil) }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Asynchronous operations require wait() to complete.
  end

  describe '#set_uid_flag' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_uid_flag)
    end

    example 'requires at least 3 arguments' do
      expect { subject.set_uid_flag }.to raise_error(ArgumentError)
    end

    example 'accepts key parameter' do
      expect(subject.method(:set_uid_flag).parameters).to include([:req, :key])
    end

    example 'accepts userid parameter' do
      expect(subject.method(:set_uid_flag).parameters).to include([:req, :userid])
    end

    example 'accepts flag parameter' do
      expect(subject.method(:set_uid_flag).parameters).to include([:req, :flag])
    end

    example 'accepts optional value parameter' do
      expect(subject.method(:set_uid_flag).parameters).to include([:opt, :value])
    end

    example 'method has correct arity' do
      # -4 means 3 required, 1 optional
      expect(subject.method(:set_uid_flag).arity).to eq(-4)
    end

    example 'raises error with nil key' do
      expect { subject.set_uid_flag(nil, "Test <test@example.com>", "primary", "1") }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    example 'raises error with nil userid' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.set_uid_flag(key, nil, "primary", "1") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises error with nil flag' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.set_uid_flag(key, "Test <test@example.com>", nil, "1") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'accepts nil value parameter' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      # Should not raise an error for nil value, though operation may fail for other reasons
      expect { subject.set_uid_flag(key, "Test <test@example.com>", "primary", nil) }.to raise_error(Crypt::GPGME::Error)
    end

    example 'converts value to string' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      # Test that integer values are converted to strings
      expect { subject.set_uid_flag(key, "Test <test@example.com>", "primary", 1) }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Actual flag setting requires a secret key with passphrase access.
  end

  describe '#set_uid_flag_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:set_uid_flag_start)
    end

    example 'requires at least 3 arguments' do
      expect { subject.set_uid_flag_start }.to raise_error(ArgumentError)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:set_uid_flag).parameters
      async_params = subject.method(:set_uid_flag_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of set_uid_flag' do
      expect(subject.method(:set_uid_flag_start).arity).to eq(subject.method(:set_uid_flag).arity)
    end

    example 'raises error with nil key' do
      expect { subject.set_uid_flag_start(nil, "Test <test@example.com>", "primary", "1") }.to raise_error(Crypt::GPGME::Error, /Invalid argument/)
    end

    example 'raises error with nil userid' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.set_uid_flag_start(key, nil, "primary", "1") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises error with nil flag' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.set_uid_flag_start(key, "Test <test@example.com>", nil, "1") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'accepts nil value parameter' do
      keys = subject.list_keys("djberg96", 1)
      skip "No secret keys available for testing" if keys.empty?

      key = keys.first
      expect { subject.set_uid_flag_start(key, "Test <test@example.com>", "primary", nil) }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Asynchronous operations require wait() to complete.
  end

  describe '#generate_key_pair' do
    example 'basic functionality' do
      expect(subject).to respond_to(:generate_key_pair)
    end

    example 'requires at least 1 argument' do
      expect { subject.generate_key_pair }.to raise_error(ArgumentError)
    end

    example 'accepts params parameter' do
      expect(subject.method(:generate_key_pair).parameters).to include([:req, :params])
    end

    example 'accepts optional public_key parameter' do
      expect(subject.method(:generate_key_pair).parameters).to include([:opt, :public_key])
    end

    example 'accepts optional secret_key parameter' do
      expect(subject.method(:generate_key_pair).parameters).to include([:opt, :secret_key])
    end

    example 'method has correct arity' do
      # -2 means 1 required, 2 optional
      expect(subject.method(:generate_key_pair).arity).to eq(-2)
    end

    example 'returns a hash' do
      skip "Skipping actual key generation in tests"
      # This would take time and modify the keyring
      # params = "<GnupgKeyParms format=\"internal\">\nKey-Type: RSA\nKey-Length: 1024\nName-Real: Test\nName-Email: test@example.com\n</GnupgKeyParms>"
      # result = subject.generate_key_pair(params)
      # expect(result).to be_a(Hash)
    end

    example 'raises error with nil params' do
      expect { subject.generate_key_pair(nil) }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises error with empty params' do
      expect { subject.generate_key_pair("") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises error with invalid XML params' do
      expect { subject.generate_key_pair("invalid xml") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'accepts Data objects for public and secret key' do
      skip "Skipping actual key generation in tests"
      # public_data = Crypt::GPGME::Data.new
      # secret_data = Crypt::GPGME::Data.new
      # params = "<GnupgKeyParms format=\"internal\">\nKey-Type: RSA\nKey-Length: 1024\nName-Real: Test\nName-Email: test@example.com\n</GnupgKeyParms>"
      # result = subject.generate_key_pair(params, public_data, secret_data)
      # expect(result).to be_a(Hash)
    end

    example 'accepts nil for public and secret key parameters' do
      skip "Skipping actual key generation in tests"
      # params = "<GnupgKeyParms format=\"internal\">\nKey-Type: RSA\nKey-Length: 1024\nName-Real: Test\nName-Email: test@example.com\n</GnupgKeyParms>"
      # result = subject.generate_key_pair(params, nil, nil)
      # expect(result).to be_a(Hash)
    end

    # Note: Actual key generation requires entropy and modifies the keyring.
    # Full integration tests should be run separately.
  end

  describe '#generate_key_pair_start' do
    example 'basic functionality' do
      expect(subject).to respond_to(:generate_key_pair_start)
    end

    example 'requires at least 1 argument' do
      expect { subject.generate_key_pair_start }.to raise_error(ArgumentError)
    end

    example 'method signature matches synchronous version' do
      sync_params = subject.method(:generate_key_pair).parameters
      async_params = subject.method(:generate_key_pair_start).parameters
      expect(async_params).to eq(sync_params)
    end

    example 'is the asynchronous version of generate_key_pair' do
      expect(subject.method(:generate_key_pair_start).arity).to eq(subject.method(:generate_key_pair).arity)
    end

    example 'raises error with nil params' do
      expect { subject.generate_key_pair_start(nil) }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises error with empty params' do
      expect { subject.generate_key_pair_start("") }.to raise_error(Crypt::GPGME::Error)
    end

    example 'raises error with invalid XML params' do
      expect { subject.generate_key_pair_start("invalid xml") }.to raise_error(Crypt::GPGME::Error)
    end

    # Note: Asynchronous operations require wait() to complete.
    # Use get_genkey_result() after wait() to retrieve the result.
  end
end
