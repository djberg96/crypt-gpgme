require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    # The Context class is the main interface for GPGME operations.
    # It encapsulates the context of cryptographic operations and provides
    # methods to configure and execute GPG operations.
    class Context
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

      # Creates a new GPGME context.
      #
      # @yield [Context] if a block is given, yields the context to the block
      # @raise [Crypt::GPGME::Error] if context creation fails
      #
      # @example
      #   ctx = Crypt::GPGME::Context.new
      #
      # @example With a block
      #   Crypt::GPGME::Context.new do |ctx|
      #     ctx.armor = true
      #     keys = ctx.list_keys
      #   end
      def initialize
        @ctx = Structs::Context.new
        @released = false
        @progress_callback = nil
        @status_callback = nil
        gpgme_check_version(nil)
        err = gpgme_new(@ctx)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_new failed: #{errstr}"
        end

        yield self if block_given?
      end

      # Sets whether output should be ASCII armored.
      #
      # @param bool [Boolean] true to enable ASCII armor, false to disable
      # @return [Boolean] the value set
      #
      # @example
      #   ctx.armor = true
      def armor=(bool)
        gpgme_set_armor(@ctx.pointer, bool)
      end

      # Returns whether ASCII armor is enabled.
      #
      # @return [Boolean] true if ASCII armor is enabled, false otherwise
      #
      # @example
      #   ctx.armor = true
      #   ctx.armor? # => true
      def armor?
        gpgme_get_armor(@ctx.pointer)
      end

      # Gets the value of a context flag.
      #
      # @param name [String] the name of the flag to retrieve
      # @return [String, nil] the flag value, or nil if not set
      #
      # @example
      #   value = ctx.get_flag("redraw")
      def get_flag(name)
        gpgme_get_ctx_flag(@ctx.pointer, name)
      end

      # Sets a context flag.
      #
      # @param name [String] the name of the flag to set
      # @param value [String] the value to set
      # @return [Hash] a hash with the flag name and value
      # @raise [Crypt::GPGME::Error] if setting the flag fails
      #
      # @example
      #   ctx.set_flag("redraw", "1")
      def set_flag(name, value)
        err = gpme_set_ctx_flag(@ctx.pointer, name, value)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_ctx_flag failed: #{errstr}"
        end

        {name => value}
      end

      # Gets information about the crypto engines.
      #
      # @return [Array<Hash>] an array of hashes containing engine information
      #   Each hash contains:
      #   - :protocol [String] the protocol name (e.g., "OpenPGP", "CMS")
      #   - :file_name [String] the path to the engine executable
      #   - :home_dir [String, nil] the home directory for the engine
      #   - :version [String] the engine version
      #   - :req_version [String] the required engine version
      #
      # @example
      #   engines = ctx.get_engine_info
      #   engines.each do |engine|
      #     puts "#{engine[:protocol]}: #{engine[:version]}"
      #   end
      def get_engine_info
        ptr = gpgme_ctx_get_engine_info(@ctx.pointer)
        info = Crypt::GPGME::Structs::EngineInfo.new(ptr)

        arr = []
        return arr if info.null?

        while !info[:next].null?
          arr << {
            :protocol    => gpgme_get_protocol_name(info[:protocol]),
            :file_name   => info[:file_name],
            :home_dir    => info[:home_dir],
            :version     => info[:version],
            :req_version => info[:req_version]
          } if info[:version]

          info = Structs::EngineInfo.new(info[:next])
        end

        arr
      end

      # Gets a key by its fingerprint.
      #
      # @param fingerprint [String] the fingerprint of the key to retrieve
      # @param secret [Boolean] whether to retrieve a secret key (default: true)
      # @return [Crypt::GPGME::Structs::Key] the key object
      # @raise [Crypt::GPGME::Error] if the key cannot be found
      #
      # @example
      #   key = ctx.get_key("C9D83C01003594990E2FE6C63D4155066C03D7EB")
      #
      # @example Get a public key
      #   key = ctx.get_key("C9D83C01003594990E2FE6C63D4155066C03D7EB", false)
      def get_key(fingerprint, secret = true)
        key = FFI::MemoryPointer.new(:pointer)
        err = gpgme_get_key(@ctx.pointer, fingerprint, key, secret)

        if err == GPG_ERR_NO_ERROR
          key = Crypt::GPGME::Structs::Key.new(key.read_pointer)
        else
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_get_key failed: #{errstr}"
        end

        key
      end

      # Sets the engine information for a specific protocol.
      #
      # @param proto [Integer] the protocol constant (e.g., GPGME_PROTOCOL_OpenPGP)
      # @param file_name [String] the path to the engine executable
      # @param home_dir [String] the home directory for the engine
      # @return [void]
      #
      # @example
      #   ctx.set_engine_info(GPGME_PROTOCOL_OpenPGP, "/usr/bin/gpg2", "/home/user/.gnupg")
      def set_engine_info(proto, file_name, home_dir)
        gpgme_ctx_set_engine_info(@ctx.pointer, proto, file_name, home_dir)
      end

      # Gets the number of certificates to include in S/MIME signed messages.
      #
      # @return [Integer] the number of certificates to include
      #   - -2: include all certificates except the root certificate
      #   - -1: include all certificates
      #   - 0: include no certificates
      #   - 1+: include this many certificates in the chain
      #
      # @example
      #   num_certs = ctx.include_certs
      def include_certs
        gpgme_get_include_certs(@ctx.pointer)
      end

      # Sets the number of certificates to include in S/MIME signed messages.
      #
      # @param num [Integer] the number of certificates to include
      # @return [Integer] the value set
      #
      # @example
      #   ctx.include_certs = -1  # Include all certificates
      def include_certs=(num)
        gpgme_set_include_certs(@ctx.pointer, num)
      end

      # Gets the current keylist mode.
      #
      # @param human_readable [Boolean] if true, returns a human-readable string
      # @return [Integer, String] the keylist mode as an integer (default) or
      #   a human-readable string of flag names separated by " | "
      #
      # @example Get numeric mode
      #   mode = ctx.keylist_mode  # => 1
      #
      # @example Get human-readable mode
      #   mode = ctx.keylist_mode(human_readable: true)  # => "LOCAL"
      #
      # @example Multiple flags
      #   ctx.keylist_mode = GPGME_KEYLIST_MODE_LOCAL | GPGME_KEYLIST_MODE_SIGS
      #   ctx.keylist_mode(human_readable: true)  # => "LOCAL | SIGS"
      def keylist_mode(human_readable: false)
        mode = gpgme_get_keylist_mode(@ctx.pointer)

        return mode unless human_readable

        flags = []
        flags << 'LOCAL' if (mode & GPGME_KEYLIST_MODE_LOCAL) != 0
        flags << 'EXTERN' if (mode & GPGME_KEYLIST_MODE_EXTERN) != 0
        flags << 'SIGS' if (mode & GPGME_KEYLIST_MODE_SIGS) != 0
        flags << 'SIG_NOTATIONS' if (mode & GPGME_KEYLIST_MODE_SIG_NOTATIONS) != 0
        flags << 'WITH_SECRET' if (mode & GPGME_KEYLIST_MODE_WITH_SECRET) != 0
        flags << 'WITH_TOFU' if (mode & GPGME_KEYLIST_MODE_WITH_TOFU) != 0
        flags << 'WITH_KEYGRIP' if (mode & GPGME_KEYLIST_MODE_WITH_KEYGRIP) != 0
        flags << 'EPHEMERAL' if (mode & GPGME_KEYLIST_MODE_EPHEMERAL) != 0
        flags << 'VALIDATE' if (mode & GPGME_KEYLIST_MODE_VALIDATE) != 0
        flags << 'FORCE_EXTERN' if (mode & GPGME_KEYLIST_MODE_FORCE_EXTERN) != 0
        flags << 'WITH_V5FPR' if (mode & GPGME_KEYLIST_MODE_WITH_V5FPR) != 0

        flags.empty? ? 'NONE' : flags.join(' | ')
      end

      # Sets the keylist mode.
      #
      # @param mode [Integer] bitwise OR of GPGME_KEYLIST_MODE_* constants
      # @return [Integer] the mode that was set
      # @raise [Crypt::GPGME::Error] if setting the mode fails
      #
      # @example Set local mode
      #   ctx.keylist_mode = GPGME_KEYLIST_MODE_LOCAL
      #
      # @example Set multiple modes
      #   ctx.keylist_mode = GPGME_KEYLIST_MODE_LOCAL | GPGME_KEYLIST_MODE_SIGS
      def keylist_mode=(mode)
        err = gpgme_set_keylist_mode(@ctx.pointer, mode)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_keylist_mode failed: #{errstr}"
        end

        mode
      end

      # Sets the locale for the context.
      #
      # @param category [Integer] the locale category (e.g., LC_CTYPE, LC_MESSAGES)
      # @param value [String] the locale value (e.g., "en_US.UTF-8")
      # @return [Hash] a hash with the category and value
      # @raise [Crypt::GPGME::Error] if setting the locale fails
      #
      # @example
      #   ctx.set_locale(LC_CTYPE, "en_US.UTF-8")
      def set_locale(category, value)
        err = gpgme_set_locale(@ctx.pointer, category, value)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_locale failed: #{errstr}"
        end

        {category => value}
      end

      # Sets the TOFU policy for a key.
      #
      # TOFU (Trust On First Use) is a trust model that automatically trusts
      # keys on first use.
      #
      # @param key [Crypt::GPGME::Structs::Key] the key to set the policy for
      # @param value [Integer] the TOFU policy value
      # @return [Integer] the policy value that was set
      # @raise [Crypt::GPGME::Error] if setting the policy fails
      #
      # @example
      #   key = ctx.get_key("C9D83C01003594990E2FE6C63D4155066C03D7EB")
      #   ctx.set_tofu_policy(key, GPGME_TOFU_POLICY_GOOD)
      def set_tofu_policy(key, value)
        err = gpgme_op_tofu_policy(@ctx.pointer, key, value)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_tofu_policy failed: #{errstr}"
        end

        value
      end

      # Gets the current protocol.
      #
      # @return [Integer] the protocol constant (e.g., GPGME_PROTOCOL_OpenPGP)
      #
      # @example
      #   proto = ctx.protocol
      def protocol
        gpgme_get_protocol(@ctx.pointer)
      end

      # Sets the protocol to use for crypto operations.
      #
      # @param proto [Integer] the protocol constant (e.g., GPGME_PROTOCOL_OpenPGP, GPGME_PROTOCOL_CMS)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if setting the protocol fails
      #
      # @example
      #   ctx.protocol = GPGME_PROTOCOL_OpenPGP
      def protocol=(proto)
        err = gpgme_set_protocol(@ctx.pointer, proto)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_protocol failed: #{errstr}"
        end
      end

      # Returns whether the context is in offline mode.
      #
      # In offline mode, GPGME will not contact external key servers.
      #
      # @return [Boolean] true if offline mode is enabled, false otherwise
      #
      # @example
      #   ctx.offline? # => false
      def offline?
        gpgme_get_offline(@ctx.pointer)
      end

      # Sets whether the context should operate in offline mode.
      #
      # @param bool [Boolean] true to enable offline mode, false to disable
      # @return [Boolean] the value set
      #
      # @example
      #   ctx.offline = true
      def offline=(bool)
        gpgme_set_offline(@ctx.pointer, bool)
      end

      # Gets the current pinentry mode.
      #
      # @return [Integer] the pinentry mode constant
      #
      # @example
      #   mode = ctx.pinentry_mode
      def pinentry_mode
        gpgme_get_pinentry_mode(@ctx.pointer)
      end

      # Sets the pinentry mode for password/passphrase prompts.
      #
      # @param mode [Integer] the pinentry mode constant (e.g., GPGME_PINENTRY_MODE_DEFAULT,
      #   GPGME_PINENTRY_MODE_ASK, GPGME_PINENTRY_MODE_CANCEL, GPGME_PINENTRY_MODE_ERROR,
      #   GPGME_PINENTRY_MODE_LOOPBACK)
      # @return [Integer] the mode that was set
      #
      # @example
      #   ctx.pinentry_mode = GPGME_PINENTRY_MODE_LOOPBACK
      def pinentry_mode=(mode)
        gpgme_set_pinentry_mode(@ctx.pointer, mode)
      end

      # Gets the sender address.
      #
      # The sender address is used for signing operations to specify the
      # sender's email address.
      #
      # @return [String, nil] the sender address, or nil if not set
      #
      # @example
      #   ctx.sender # => "alice@example.com"
      def sender
        gpgme_get_sender(@ctx.pointer)
      end

      # Sets the sender address.
      #
      # The sender address is used for signing operations to specify the
      # sender's email address. The address should be in RFC-2822 format.
      #
      # @param address [String] the sender address (e.g., "alice@example.com")
      # @return [String] the address that was set
      # @raise [Crypt::GPGME::Error] if setting the sender fails
      #
      # @example
      #   ctx.sender = "alice@example.com"
      #
      # @example With a display name
      #   ctx.sender = "Alice <alice@example.com>"
      def sender=(address)
        err = gpgme_set_sender(@ctx.pointer, address)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_sender failed: #{errstr}"
        end

        address
      end

      # Sets a progress callback for monitoring long-running operations.
      #
      # The callback will be invoked periodically during operations that may
      # take a long time (e.g., key generation, encryption of large files).
      #
      # @param callback [Proc, nil] a proc that receives progress updates, or nil to clear
      #   The proc should accept 4 parameters:
      #   - what [String]: description of the operation (e.g., "primegen", "keygen")
      #   - type [Integer]: type of progress (operation-specific)
      #   - current [Integer]: current progress value
      #   - total [Integer]: total progress value (0 if unknown)
      # @return [Proc, nil] the callback that was set
      #
      # @example Set a progress callback
      #   ctx.set_progress_callback do |what, type, current, total|
      #     if total > 0
      #       percent = (current * 100.0 / total).to_i
      #       puts "#{what}: #{percent}% (#{current}/#{total})"
      #     else
      #       puts "#{what}: #{current}"
      #     end
      #   end
      #
      # @example Clear the progress callback
      #   ctx.set_progress_callback(nil)
      def set_progress_callback(callback = nil, &block)
        callback = block if block_given?

        if callback.nil?
          # Clear the callback
          gpgme_set_progress_cb(@ctx.pointer, nil, nil)
          @progress_callback = nil
        else
          # Store the callback to prevent garbage collection
          @progress_callback = callback

          # Create an FFI callback wrapper
          ffi_callback = Proc.new do |opaque, what, type, current, total|
            begin
              callback.call(what, type, current, total)
            rescue => e
              warn "Progress callback error: #{e.message}"
            end
          end

          gpgme_set_progress_cb(@ctx.pointer, ffi_callback, nil)
        end

        callback
      end

      # Gets the current progress callback.
      #
      # @return [Proc, nil] the current progress callback, or nil if not set
      #
      # @example
      #   callback = ctx.progress_callback
      def progress_callback
        @progress_callback
      end

      # Sets a status callback for receiving status messages from operations.
      #
      # The callback will be invoked during cryptographic operations to report
      # status information about what's happening (e.g., key selection, signature
      # verification results, etc.).
      #
      # @param callback [Proc, nil] a proc that receives status messages, or nil to clear
      #   The proc should accept 2 parameters:
      #   - keyword [String]: the status keyword (e.g., "GOODSIG", "BADSIG", "KEYEXPIRED")
      #   - args [String]: arguments associated with the status message
      #   The proc should return 0 on success or an error code on failure
      # @return [Proc, nil] the callback that was set
      #
      # @example Set a status callback
      #   ctx.set_status_callback do |keyword, args|
      #     puts "Status: #{keyword} - #{args}"
      #     0  # Return 0 for success
      #   end
      #
      # @example Clear the status callback
      #   ctx.set_status_callback(nil)
      def set_status_callback(callback = nil, &block)
        callback = block if block_given?

        if callback.nil?
          # Clear the callback
          gpgme_set_status_cb(@ctx.pointer, nil, nil)
          @status_callback = nil
        else
          # Store the callback to prevent garbage collection
          @status_callback = callback

          # Create an FFI callback wrapper
          ffi_callback = Proc.new do |opaque, keyword, args|
            begin
              result = callback.call(keyword, args)
              result.is_a?(Integer) ? result : 0
            rescue => e
              warn "Status callback error: #{e.message}"
              0  # Return success to avoid breaking the operation
            end
          end

          gpgme_set_status_cb(@ctx.pointer, ffi_callback, nil)
        end

        callback
      end

      # Gets the current status callback.
      #
      # @return [Proc, nil] the current status callback, or nil if not set
      #
      # @example
      #   callback = ctx.status_callback
      def status_callback
        @status_callback
      end

      # Retrieves the audit log for the most recent operation.
      #
      # This method can be called after a cryptographic operation (successful or failed)
      # to retrieve detailed audit information about what happened during the operation.
      #
      # @param flags [Integer] flags controlling the audit log format
      #   Available flags:
      #   - GPGME_AUDITLOG_DEFAULT (0): Default format
      #   - GPGME_AUDITLOG_HTML (1): HTML format
      #   - GPGME_AUDITLOG_DIAG (2): Diagnostic format
      #   - GPGME_AUDITLOG_WITH_HELP (128): Include help text (can be combined with other flags)
      # @return [String] the audit log as a string
      # @raise [Crypt::GPGME::Error] if retrieving the audit log fails
      #
      # @example Get default format audit log
      #   audit_log = ctx.get_audit_log
      #
      # @example Get HTML format audit log
      #   audit_log = ctx.get_audit_log(GPGME_AUDITLOG_HTML)
      #
      # @example Get HTML format with help text
      #   audit_log = ctx.get_audit_log(GPGME_AUDITLOG_HTML | GPGME_AUDITLOG_WITH_HELP)
      def get_audit_log(flags = GPGME_AUDITLOG_DEFAULT)
        # Create a data object to hold the audit log
        output = Structs::Data.new
        err = gpgme_data_new(output)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new failed: #{errstr}"
        end

        # Get the audit log
        err = gpgme_op_getauditlog(@ctx.pointer, output.pointer, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          gpgme_data_release(output.pointer)
          raise Crypt::GPGME::Error, "gpgme_op_getauditlog failed: #{errstr}"
        end

        # Read the audit log data
        gpgme_data_seek(output.pointer, 0, 0) # Seek to beginning

        result = String.new
        buffer_size = 4096
        buffer = FFI::MemoryPointer.new(:char, buffer_size)

        loop do
          bytes_read = gpgme_data_read(output.pointer, buffer, buffer_size)
          break if bytes_read <= 0
          result << buffer.read_string(bytes_read)
        end

        # Clean up
        gpgme_data_release(output.pointer)

        result
      end

      # Starts an asynchronous audit log retrieval operation.
      #
      # This is the asynchronous version of {#get_audit_log}. After calling this method,
      # you need to wait for the operation to complete before reading the audit log.
      #
      # @param flags [Integer] flags controlling the audit log format (see {#get_audit_log})
      # @return [Crypt::GPGME::Structs::Data] the data object that will contain the audit log
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example
      #   output = ctx.get_audit_log_start(GPGME_AUDITLOG_HTML)
      #   # Wait for operation to complete...
      #   # Read from output data object
      def get_audit_log_start(flags = GPGME_AUDITLOG_DEFAULT)
        output = Structs::Data.new
        err = gpgme_data_new(output)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new failed: #{errstr}"
        end

        err = gpgme_op_getauditlog_start(@ctx.pointer, output.pointer, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          gpgme_data_release(output.pointer)
          raise Crypt::GPGME::Error, "gpgme_op_getauditlog_start failed: #{errstr}"
        end

        output
      end

      # Signs data.
      #
      # @param data [Crypt::GPGME::Structs::Data] the data to sign
      # @param sig [Crypt::GPGME::Structs::KeySig] the signature object (default: new KeySig)
      # @param mode [Integer] the signature mode (default: GPGME_SIG_MODE_NORMAL)
      #   Available modes:
      #   - GPGME_SIG_MODE_NORMAL: Normal signature
      #   - GPGME_SIG_MODE_DETACH: Detached signature
      #   - GPGME_SIG_MODE_CLEAR: Clear text signature
      # @return [Crypt::GPGME::Structs::KeySig] the signature object
      # @raise [Crypt::GPGME::Error] if signing fails
      #
      # @example
      #   data = Crypt::GPGME::Structs::Data.new("Hello, World!")
      #   sig = ctx.sign(data)
      def sign(data, sig = Crypt::GPGME::Structs::KeySig.new, mode = GPGME_SIG_MODE_NORMAL)
        err = gpgme_op_sign(@ctx.pointer, data, sig, mode)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_sign failed: #{errstr}"
        end

        sig
      end

      # Returns whether text mode is enabled.
      #
      # Text mode affects how data is processed (e.g., line ending conversion).
      #
      # @return [Boolean] true if text mode is enabled, false otherwise
      #
      # @example
      #   ctx.text_mode? # => false
      def text_mode?
        gpgme_get_textmode(@ctx.pointer)
      end

      # Sets whether text mode should be enabled.
      #
      # @param bool [Boolean] true to enable text mode, false to disable
      # @return [Boolean] the value set
      #
      # @example
      #   ctx.text_mode = true
      def text_mode=(bool)
        gpgme_set_textmode(@ctx.pointer, bool)
      end

      # Returns whether the context has been released.
      #
      # @return [Boolean] true if the context has been released, false otherwise
      #
      # @example
      #   ctx.released? # => false
      #   ctx.release
      #   ctx.released? # => true
      def released?
        @released
      end

      # Releases the context and frees associated resources.
      #
      # This method can be called multiple times safely. After the first call,
      # subsequent calls will have no effect.
      #
      # @return [void]
      #
      # @example
      #   ctx.release
      #   ctx.released? # => true
      def release
        return if @released

        if !@ctx.pointer.null?
          gpgme_release(@ctx.pointer)
          @released = true
        end
      end

      # Lists keys matching the given pattern.
      #
      # @param pattern [String, nil] the pattern to match (e.g., email, name, fingerprint).
      #   If nil, lists all keys.
      # @param secret [Integer] if non-zero, lists secret (private) keys only.
      #   If zero (default), lists public keys.
      # @return [Array<Hash>] an array of hashes containing key information.
      #   Each hash contains detailed information about the key including:
      #   - :fpr - fingerprint
      #   - :uids - array of user IDs
      #   - :subkeys - array of subkeys
      #   - :can_encrypt, :can_sign, :can_certify - capability flags
      #   - and many other fields
      # @raise [Crypt::GPGME::Error] if the key listing operation fails
      #
      # @example List all public keys
      #   keys = ctx.list_keys
      #
      # @example List keys matching a pattern
      #   keys = ctx.list_keys("alice@example.com")
      #
      # @example List secret keys
      #   keys = ctx.list_keys(nil, 1)
      #
      # @example List secret keys for a specific user
      #   keys = ctx.list_keys("bob@example.com", 1)
      def list_keys(pattern = nil, secret = 0)
        err = gpgme_op_keylist_start(@ctx.pointer, pattern, secret)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_keylist_start failed: #{errstr}"
        end

        arr = []

        while err == GPG_ERR_NO_ERROR
          key_ptr = FFI::MemoryPointer.new(:pointer)
          err = gpgme_op_keylist_next(@ctx.pointer, key_ptr)
          break if err != GPG_ERR_NO_ERROR
          key = Structs::Key.new(key_ptr.read_pointer)
          arr << key.to_hash
          gpgme_key_unref(key)
        end

        err = gpgme_op_keylist_end(@ctx.pointer)

        if err != GPG_ERR_EOF && err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_keylist_end failed: #{errstr}"
        end

        arr
      end
    end
  end
end

if $0 == __FILE__
  ctx = Crypt::GPGME::Context.new
  p ctx.list_keys("djberg96").first
  p ctx.get_engine_info
  p ctx.keylist_mode
end
