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

            # Lists keys in the keyring.
      #
      # @param pattern [String, Array<String>, Crypt::GPGME::Data, Crypt::GPGME::Structs::Data, nil] pattern(s) to match keys against, or nil for all keys
      #   Can be a single string pattern, an array of string patterns, or a Data object containing key data
      # @param secret [Integer] 0 for public keys, 1 for secret keys (ignored when pattern is a Data object)
      # @param format [Symbol] :hash to return key hashes (default), :object to return Key structs
      # @return [Array<Hash>, Array<Structs::Key>] array of key hashes or Key struct objects depending on format parameter
      # @raise [Crypt::GPGME::Error] if the keylist operation fails
      #
      # @example List all keys as hashes
      #   keys = ctx.list_keys
      #
      # @example List all keys as objects
      #   keys = ctx.list_keys(nil, 0, :object)
      #
      # @example List keys matching a pattern
      #   keys = ctx.list_keys("alice@example.com")
      #
      # @example List keys matching multiple patterns
      #   keys = ctx.list_keys(["alice@example.com", "bob@example.com", "carol@example.com"])
      #
      # @example List keys from custom data
      #   data = Crypt::GPGME::Data.new(key_string)
      #   keys = ctx.list_keys(data)
      #
      # @example List secret keys
      #   keys = ctx.list_keys(nil, 1)
      #
      # @example List secret keys for specific users
      #   keys = ctx.list_keys(["alice@example.com", "bob@example.com"], 1)
      #
      # @example List keys as objects for use with export_keys_by_object
      #   keys = ctx.list_keys("alice@example.com", 0, :object)
      #   keydata = Crypt::GPGME::Data.new(Crypt::GPGME::Structs::Data.new)
      #   ctx.export_keys_by_object(keys, keydata)
      def list_keys(pattern = nil, secret = 0, format = :hash)
        if pattern.is_a?(Data) || pattern.is_a?(Structs::Data)
          # Use gpgme_op_keylist_from_data_start for data objects
          data_ptr = pattern.is_a?(Data) ? pattern.instance_variable_get(:@data).pointer : pattern.pointer
          err = gpgme_op_keylist_from_data_start(@ctx.pointer, data_ptr, 0)
        elsif pattern.is_a?(Array)
          # Use gpgme_op_keylist_ext_start for multiple patterns
          # Create a NULL-terminated array of string pointers
          pattern_ptrs = pattern.map { |p| FFI::MemoryPointer.from_string(p.to_s) }
          pattern_ptrs << nil  # NULL terminator

          patterns_array = FFI::MemoryPointer.new(:pointer, pattern_ptrs.size)
          pattern_ptrs.each_with_index do |ptr, i|
            patterns_array[i].put_pointer(0, ptr)
          end

          err = gpgme_op_keylist_ext_start(@ctx.pointer, patterns_array, secret, 0)
        else
          # Use gpgme_op_keylist_start for single pattern or nil
          err = gpgme_op_keylist_start(@ctx.pointer, pattern, secret)
        end

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

          if format == :object
            arr << key
          else
            arr << key.to_hash
            gpgme_key_unref(key)
          end
        end

        err = gpgme_op_keylist_end(@ctx.pointer)

        if err != GPG_ERR_EOF && err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_keylist_end failed: #{errstr}"
        end

        arr
      end

      # Sets the expiration time for a key or its subkeys (synchronous).
      #
      # This method changes the expiration time of a key or specific subkeys.
      # By default, it changes the expiration of the primary key. To change
      # specific subkeys, provide their fingerprints in the +subfprs+ parameter.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param expires [Integer] the expiration time in seconds from now, or 0 for no expiration
      # @param subfprs [String, nil] optional newline-separated fingerprints of subkeys to modify,
      #   or nil to modify the primary key only
      # @param reserved [Integer] reserved parameter, must be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Set primary key to expire in 1 year
      #   key = ctx.list_keys("user@example.com").first
      #   ctx.set_expire(key, 365 * 24 * 60 * 60)
      #
      # @example Set primary key to never expire
      #   ctx.set_expire(key, 0)
      #
      # @example Set specific subkeys to expire in 6 months
      #   ctx.set_expire(key, 180 * 24 * 60 * 60, "FPR1\nFPR2")
      #
      # @note This operation requires the key's passphrase
      # @note Time is relative to the current moment, not absolute
      def set_expire(key, expires, subfprs = nil, reserved = 0)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_setexpire(@ctx.pointer, key_struct, expires, subfprs, reserved)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_setexpire failed: #{errstr}"
        end

        nil
      end

      # Sets the expiration time for a key or its subkeys (asynchronous).
      #
      # This is the asynchronous version of {#set_expire}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param expires [Integer] the expiration time in seconds from now, or 0 for no expiration
      # @param subfprs [String, nil] optional newline-separated fingerprints of subkeys to modify,
      #   or nil to modify the primary key only
      # @param reserved [Integer] reserved parameter, must be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Set key expiration asynchronously
      #   key = ctx.list_keys("user@example.com").first
      #   ctx.set_expire_start(key, 365 * 24 * 60 * 60)
      #   ctx.wait
      #
      # @note This operation requires the key's passphrase
      # @note Time is relative to the current moment, not absolute
      def set_expire_start(key, expires, subfprs = nil, reserved = 0)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_setexpire_start(@ctx.pointer, key_struct, expires, subfprs, reserved)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_setexpire_start failed: #{errstr}"
        end

        nil
      end

      # Sets the owner trust for a key (synchronous).
      #
      # This method changes the owner trust level of an OpenPGP key. Owner trust
      # indicates how much you trust the key owner to properly verify other keys.
      # This is different from key validity - owner trust is your personal assessment
      # of the key owner's trustworthiness as a key certifier.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param value [String, Integer] the trust value, either:
      #   - A string: "unknown", "undefined", "never", "marginal", "full", or "ultimate"
      #   - An integer: 0-5 corresponding to GPGME_VALIDITY_* constants
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Set owner trust to full
      #   key = ctx.list_keys("user@example.com").first
      #   ctx.set_owner_trust(key, "full")
      #
      # @example Set owner trust to ultimate
      #   ctx.set_owner_trust(key, "ultimate")
      #
      # @example Set owner trust using integer constant
      #   ctx.set_owner_trust(key, GPGME_VALIDITY_FULL)
      #
      # @note This operation is OpenPGP-specific
      # @note This operation requires appropriate permissions
      # @note Owner trust levels:
      #   - "unknown" (0): Unknown trust
      #   - "undefined" (1): Undefined trust
      #   - "never" (2): Never trust this key owner to certify keys
      #   - "marginal" (3): Marginally trust this key owner
      #   - "full" (4): Fully trust this key owner to certify keys
      #   - "ultimate" (5): Ultimate trust (typically for your own keys)
      def set_owner_trust(key, value)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)

        # Convert value to string format expected by GPGME
        value_str = case value
                    when String
                      value.downcase
                    when Integer
                      case value
                      when 0, GPGME_VALIDITY_UNKNOWN then "unknown"
                      when 1, GPGME_VALIDITY_UNDEFINED then "undefined"
                      when 2, GPGME_VALIDITY_NEVER then "never"
                      when 3, GPGME_VALIDITY_MARGINAL then "marginal"
                      when 4, GPGME_VALIDITY_FULL then "full"
                      when 5, GPGME_VALIDITY_ULTIMATE then "ultimate"
                      else
                        raise ArgumentError, "Invalid trust value: #{value}. Must be 0-5."
                      end
                    else
                      raise ArgumentError, "Value must be a String or Integer, got #{value.class}"
                    end

        err = gpgme_op_setownertrust(@ctx.pointer, key_struct, value_str)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_setownertrust failed: #{errstr}"
        end

        nil
      end

      # Sets the owner trust for a key (asynchronous).
      #
      # This is the asynchronous version of {#set_owner_trust}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param value [String, Integer] the trust value (see {#set_owner_trust} for valid values)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Set owner trust asynchronously
      #   key = ctx.list_keys("user@example.com").first
      #   ctx.set_owner_trust_start(key, "full")
      #   ctx.wait
      #
      # @note This operation is OpenPGP-specific
      # @see #set_owner_trust for trust level descriptions
      def set_owner_trust_start(key, value)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)

        # Convert value to string format expected by GPGME
        value_str = case value
                    when String
                      value.downcase
                    when Integer
                      case value
                      when 0, GPGME_VALIDITY_UNKNOWN then "unknown"
                      when 1, GPGME_VALIDITY_UNDEFINED then "undefined"
                      when 2, GPGME_VALIDITY_NEVER then "never"
                      when 3, GPGME_VALIDITY_MARGINAL then "marginal"
                      when 4, GPGME_VALIDITY_FULL then "full"
                      when 5, GPGME_VALIDITY_ULTIMATE then "ultimate"
                      else
                        raise ArgumentError, "Invalid trust value: #{value}. Must be 0-5."
                      end
                    else
                      raise ArgumentError, "Value must be a String or Integer, got #{value.class}"
                    end

        err = gpgme_op_setownertrust_start(@ctx.pointer, key_struct, value_str)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_setownertrust_start failed: #{errstr}"
        end

        nil
      end

      # Creates a new primary key (synchronous).
      #
      # This method creates a new OpenPGP primary key with the specified user ID
      # and algorithm. This is the modern interface for key creation.
      #
      # @param userid [String] the user ID for the new key (e.g., "Name <email@example.com>")
      # @param algo [String, nil] the algorithm specification (e.g., "rsa2048", "ed25519", "future-default")
      #   If nil, uses "future-default"
      # @param reserved [Integer] reserved parameter, must be 0
      # @param expires [Integer] expiration time in seconds from now, or 0 for no expiration
      # @param certkey [Crypt::GPGME::Key, Structs::Key, nil] optional certification key (for subkey creation)
      # @param flags [Integer] creation flags (bitwise OR of GPGME_CREATE_* constants)
      # @return [Hash] a hash containing key creation result information
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Create a basic RSA key
      #   result = ctx.create_key("Alice <alice@example.com>", "rsa2048")
      #
      # @example Create an Ed25519 key
      #   result = ctx.create_key("Bob <bob@example.com>", "ed25519")
      #
      # @example Create key with specific capabilities
      #   flags = GPGME_CREATE_SIGN | GPGME_CREATE_ENCR
      #   result = ctx.create_key("Carol <carol@example.com>", "rsa2048", 0, 0, nil, flags)
      #
      # @example Create key that doesn't expire
      #   flags = GPGME_CREATE_NOEXPIRE
      #   result = ctx.create_key("Dave <dave@example.com>", "rsa2048", 0, 0, nil, flags)
      #
      # @note This operation requires passphrase entry via pinentry (unless GPGME_CREATE_NOPASSWD flag is set)
      # @note Common algorithms: "rsa2048", "rsa3072", "rsa4096", "ed25519", "cv25519", "future-default"
      # @note Default flags enable signing and certification
      def create_key(userid, algo = nil, reserved = 0, expires = 0, certkey = nil, flags = 0)
        algo ||= "future-default"
        certkey_struct = if certkey
                           certkey.is_a?(Structs::Key) ? certkey : certkey.instance_variable_get(:@key)
                         else
                           nil
                         end

        err = gpgme_op_createkey(@ctx.pointer, userid, algo, reserved, expires, certkey_struct, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_createkey failed: #{errstr}"
        end

        # Get the result
        result_ptr = gpgme_op_genkey_result(@ctx.pointer)
        if result_ptr.null?
          return {}
        end

        # Parse the result structure
        result = {}
        result[:fpr] = result_ptr.read_pointer.read_string unless result_ptr.read_pointer.null?
        result
      end

      # Creates a new primary key (asynchronous).
      #
      # This is the asynchronous version of {#create_key}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param userid [String] the user ID for the new key
      # @param algo [String, nil] the algorithm specification
      # @param reserved [Integer] reserved parameter, must be 0
      # @param expires [Integer] expiration time in seconds from now, or 0 for no expiration
      # @param certkey [Crypt::GPGME::Key, Structs::Key, nil] optional certification key
      # @param flags [Integer] creation flags
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Create key asynchronously
      #   ctx.create_key_start("Alice <alice@example.com>", "rsa2048")
      #   ctx.wait
      #   result = ctx.get_genkey_result
      #
      # @see #create_key for parameter descriptions and examples
      def create_key_start(userid, algo = nil, reserved = 0, expires = 0, certkey = nil, flags = 0)
        algo ||= "future-default"
        certkey_struct = if certkey
                           certkey.is_a?(Structs::Key) ? certkey : certkey.instance_variable_get(:@key)
                         else
                           nil
                         end

        err = gpgme_op_createkey_start(@ctx.pointer, userid, algo, reserved, expires, certkey_struct, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_createkey_start failed: #{errstr}"
        end

        nil
      end

      # Creates a new subkey for an existing key (synchronous).
      #
      # This method creates a new subkey (e.g., encryption subkey, signing subkey)
      # for an existing primary key. Subkeys allow different cryptographic operations
      # and can have different expiration times.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the primary key to add a subkey to
      # @param algo [String, nil] the algorithm specification (e.g., "rsa2048", "ed25519")
      #   If nil, uses "future-default"
      # @param reserved [Integer] reserved parameter, must be 0
      # @param expires [Integer] expiration time in seconds from now, or 0 for no expiration
      # @param flags [Integer] creation flags (bitwise OR of GPGME_CREATE_* constants)
      # @return [Hash] a hash containing subkey creation result information
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Create an encryption subkey
      #   key = ctx.list_keys("alice@example.com").first
      #   flags = GPGME_CREATE_ENCR
      #   result = ctx.create_subkey(key, "rsa2048", 0, 0, flags)
      #
      # @example Create a signing subkey
      #   flags = GPGME_CREATE_SIGN
      #   result = ctx.create_subkey(key, "ed25519", 0, 0, flags)
      #
      # @example Create subkey that expires in 1 year
      #   one_year = 365 * 24 * 60 * 60
      #   flags = GPGME_CREATE_ENCR
      #   result = ctx.create_subkey(key, "rsa2048", 0, one_year, flags)
      #
      # @note This operation requires the primary key's passphrase
      # @note You must specify at least one capability flag (SIGN, ENCR, CERT, or AUTH)
      # @note Common use cases: add encryption subkey to signing-only key, add subkeys with different expirations
      def create_subkey(key, algo = nil, reserved = 0, expires = 0, flags = 0)
        algo ||= "future-default"
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)

        err = gpgme_op_createsubkey(@ctx.pointer, key_struct, algo, reserved, expires, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_createsubkey failed: #{errstr}"
        end

        # Get the result
        result_ptr = gpgme_op_genkey_result(@ctx.pointer)
        if result_ptr.null?
          return {}
        end

        # Parse the result structure
        result = {}
        result[:fpr] = result_ptr.read_pointer.read_string unless result_ptr.read_pointer.null?
        result
      end

      # Creates a new subkey for an existing key (asynchronous).
      #
      # This is the asynchronous version of {#create_subkey}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the primary key to add a subkey to
      # @param algo [String, nil] the algorithm specification
      # @param reserved [Integer] reserved parameter, must be 0
      # @param expires [Integer] expiration time in seconds from now, or 0 for no expiration
      # @param flags [Integer] creation flags
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Create subkey asynchronously
      #   key = ctx.list_keys("alice@example.com").first
      #   flags = GPGME_CREATE_ENCR
      #   ctx.create_subkey_start(key, "rsa2048", 0, 0, flags)
      #   ctx.wait
      #   result = ctx.get_genkey_result
      #
      # @see #create_subkey for parameter descriptions and examples
      def create_subkey_start(key, algo = nil, reserved = 0, expires = 0, flags = 0)
        algo ||= "future-default"
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)

        err = gpgme_op_createsubkey_start(@ctx.pointer, key_struct, algo, reserved, expires, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_createsubkey_start failed: #{errstr}"
        end

        nil
      end

      # Retrieves the result of a key generation operation.
      #
      # This method returns the result of the most recent genkey, createkey, or
      # createsubkey operation. It should be called after the operation completes.
      #
      # @return [Hash] a hash containing result information:
      #   - :fpr [String] the fingerprint of the generated key/subkey
      #
      # @example Get result after synchronous operation
      #   ctx.create_key("Alice <alice@example.com>", "rsa2048")
      #   result = ctx.get_genkey_result
      #   puts "Generated key: #{result[:fpr]}"
      #
      # @example Get result after asynchronous operation
      #   ctx.create_key_start("Bob <bob@example.com>", "ed25519")
      #   ctx.wait
      #   result = ctx.get_genkey_result
      #
      # @note Returns an empty hash if no result is available
      def get_genkey_result
        result_ptr = gpgme_op_genkey_result(@ctx.pointer)
        return {} if result_ptr.null?

        result = {}
        result[:fpr] = result_ptr.read_pointer.read_string unless result_ptr.read_pointer.null?
        result
      end

      # Adds a new user ID to an existing key (synchronous).
      #
      # This method adds an additional user ID (name and email address) to an
      # existing OpenPGP key. The key must be a secret key that you own.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param userid [String] the user ID to add in the format "Name <email@example.com>"
      # @param reserved [Integer] reserved parameter, must be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Add a new email address to a key
      #   key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.add_uid(key, "Alice Smith <alice.smith@newdomain.com>")
      #
      # @example Add an alternate name
      #   ctx.add_uid(key, "Alice Jones <alice@example.com>")
      #
      # @note This operation requires the key's passphrase
      # @note The user ID format should be "Name <email@example.com>" or "Name (Comment) <email@example.com>"
      # @note The key must be a secret key
      def add_uid(key, userid, reserved = 0)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_adduid(@ctx.pointer, key_struct, userid, reserved)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_adduid failed: #{errstr}"
        end

        nil
      end

      # Adds a new user ID to an existing key (asynchronous).
      #
      # This is the asynchronous version of {#add_uid}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param userid [String] the user ID to add
      # @param reserved [Integer] reserved parameter, must be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Add user ID asynchronously
      #   key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.add_uid_start(key, "Alice <alice@newdomain.com>")
      #   ctx.wait
      #
      # @note This operation requires the key's passphrase
      # @note The key must be a secret key
      def add_uid_start(key, userid, reserved = 0)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_adduid_start(@ctx.pointer, key_struct, userid, reserved)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_adduid_start failed: #{errstr}"
        end

        nil
      end

      # Revokes a user ID from a key (synchronous).
      #
      # This method revokes (marks as invalid) a user ID on an OpenPGP key.
      # The user ID is not deleted but marked as revoked. The key must be a
      # secret key that you own.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param userid [String] the user ID to revoke (must match exactly)
      # @param reserved [Integer] reserved parameter, must be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Revoke a user ID
      #   key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.revoke_uid(key, "Alice Smith <alice.smith@olddomain.com>")
      #
      # @note This operation requires the key's passphrase
      # @note The user ID string must match exactly
      # @note The key must be a secret key
      # @note Revoked user IDs remain on the key but are marked as invalid
      def revoke_uid(key, userid, reserved = 0)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_revuid(@ctx.pointer, key_struct, userid, reserved)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_revuid failed: #{errstr}"
        end

        nil
      end

      # Revokes a user ID from a key (asynchronous).
      #
      # This is the asynchronous version of {#revoke_uid}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param userid [String] the user ID to revoke
      # @param reserved [Integer] reserved parameter, must be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Revoke user ID asynchronously
      #   key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.revoke_uid_start(key, "Old Name <old@example.com>")
      #   ctx.wait
      #
      # @note This operation requires the key's passphrase
      # @note The key must be a secret key
      def revoke_uid_start(key, userid, reserved = 0)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_revuid_start(@ctx.pointer, key_struct, userid, reserved)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_revuid_start failed: #{errstr}"
        end

        nil
      end

      # Sets a flag on a user ID (synchronous).
      #
      # This method sets or clears a flag on a specific user ID of a key.
      # The most common flag is "primary" to mark a UID as the primary one.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param userid [String] the user ID to modify (must match exactly)
      # @param flag [String] the flag name to set ("primary" is most common)
      # @param value [String, nil] the flag value: "1" to set, "0" to clear, or nil to clear
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Set a UID as primary
      #   key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")
      #
      # @example Clear primary flag
      #   ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "0")
      #
      # @example Mark primary UID (alternative syntax)
      #   ctx.set_uid_flag(key, "Alice Smith <alice@personal.net>", "primary", nil)
      #
      # @note This operation requires the key's passphrase
      # @note The user ID string must match exactly
      # @note The key must be a secret key
      # @note Setting a UID as primary automatically clears the primary flag from other UIDs
      def set_uid_flag(key, userid, flag, value = nil)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        value_str = value.nil? ? nil : value.to_s
        err = gpgme_op_set_uid_flag(@ctx.pointer, key_struct, userid, flag, value_str)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_set_uid_flag failed: #{errstr}"
        end

        nil
      end

      # Sets a flag on a user ID (asynchronous).
      #
      # This is the asynchronous version of {#set_uid_flag}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to modify
      # @param userid [String] the user ID to modify
      # @param flag [String] the flag name to set
      # @param value [String, nil] the flag value
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Set primary UID asynchronously
      #   key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.set_uid_flag_start(key, "Alice <alice@work.com>", "primary", "1")
      #   ctx.wait
      #
      # @note This operation requires the key's passphrase
      # @note The key must be a secret key
      def set_uid_flag_start(key, userid, flag, value = nil)
        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        value_str = value.nil? ? nil : value.to_s
        err = gpgme_op_set_uid_flag_start(@ctx.pointer, key_struct, userid, flag, value_str)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_set_uid_flag_start failed: #{errstr}"
        end

        nil
      end

      # Generates a complete key pair with optional subkeys using XML parameters (synchronous).
      #
      # This method generates a complete OpenPGP key pair (primary key + subkeys) using
      # XML-formatted parameters. This is more flexible than {#create_key} and allows
      # specifying detailed key generation parameters in a single operation.
      #
      # @param params [String] XML string describing the key parameters
      # @param public_key [Data, nil] optional Data object to receive the public key
      # @param secret_key [Data, nil] optional Data object to receive the secret key
      # @return [Hash] a hash containing result information:
      #   - :fpr [String] the fingerprint of the generated primary key
      #   - :primary [Boolean] whether a primary key was generated
      #   - :sub [Boolean] whether a subkey was generated
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Generate a basic RSA key pair
      #   params = <<~XML
      #     <GnupgKeyParms format="internal">
      #       Key-Type: RSA
      #       Key-Length: 2048
      #       Subkey-Type: RSA
      #       Subkey-Length: 2048
      #       Name-Real: Alice Smith
      #       Name-Email: alice@example.com
      #       Expire-Date: 0
      #     </GnupgKeyParms>
      #   XML
      #   result = ctx.generate_key_pair(params)
      #   puts "Generated key: #{result[:fpr]}"
      #
      # @example Generate an EdDSA key pair with passphrase
      #   params = <<~XML
      #     <GnupgKeyParms format="internal">
      #       Key-Type: EdDSA
      #       Key-Curve: Ed25519
      #       Subkey-Type: ECDH
      #       Subkey-Curve: Cv25519
      #       Name-Real: Bob Jones
      #       Name-Email: bob@example.com
      #       Passphrase: my-secret-passphrase
      #       Expire-Date: 1y
      #     </GnupgKeyParms>
      #   XML
      #   result = ctx.generate_key_pair(params)
      #
      # @example Generate key and capture output
      #   public_data = Crypt::GPGME::Data.new
      #   secret_data = Crypt::GPGME::Data.new
      #   result = ctx.generate_key_pair(params, public_data, secret_data)
      #
      #   public_key_text = public_data.read
      #   secret_key_text = secret_data.read
      #
      # @note This operation may take some time depending on key size and system entropy
      # @note The XML format is documented in the GPGME manual
      # @note Without a passphrase in the XML, the key will be generated without protection
      # @see https://www.gnupg.org/documentation/manuals/gpgme/Generating-Keys.html
      def generate_key_pair(params, public_key = nil, secret_key = nil)
        # Validate parameters
        raise Crypt::GPGME::Error, "params cannot be nil" if params.nil?
        raise Crypt::GPGME::Error, "params cannot be empty" if params.to_s.empty?

        pub_ptr = public_key ? (public_key.is_a?(Data) ? public_key.instance_variable_get(:@data).pointer : public_key.pointer) : nil
        sec_ptr = secret_key ? (secret_key.is_a?(Data) ? secret_key.instance_variable_get(:@data).pointer : secret_key.pointer) : nil

        err = gpgme_op_genkey(@ctx.pointer, params, pub_ptr, sec_ptr)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_genkey failed: #{errstr}"
        end

        # Get the result
        result_ptr = gpgme_op_genkey_result(@ctx.pointer)
        if result_ptr.null?
          return {}
        end

        # Parse the result structure
        # typedef struct {
        #   unsigned int primary : 1;
        #   unsigned int sub : 1;
        #   char *fpr;
        # } gpgme_genkey_result_t;
        result = {}

        # Read the bitfield flags (first 4 bytes typically)
        flags = result_ptr.read_uint
        result[:primary] = (flags & 0x1) != 0
        result[:sub] = (flags & 0x2) != 0

        # Read the fingerprint pointer (offset depends on struct padding)
        # Try reading at offset 4 or 8 depending on architecture
        fpr_ptr = result_ptr.get_pointer(FFI::Pointer.size == 8 ? 8 : 4)
        result[:fpr] = fpr_ptr.read_string unless fpr_ptr.null?

        result
      end

      # Generates a complete key pair with optional subkeys using XML parameters (asynchronous).
      #
      # This is the asynchronous version of {#generate_key_pair}. It initiates the
      # operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param params [String] XML string describing the key parameters
      # @param public_key [Data, nil] optional Data object to receive the public key
      # @param secret_key [Data, nil] optional Data object to receive the secret key
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Generate key pair asynchronously
      #   params = <<~XML
      #     <GnupgKeyParms format="internal">
      #       Key-Type: RSA
      #       Key-Length: 2048
      #       Name-Real: Charlie Brown
      #       Name-Email: charlie@example.com
      #     </GnupgKeyParms>
      #   XML
      #   ctx.generate_key_pair_start(params)
      #   ctx.wait
      #   result = ctx.get_genkey_result
      #
      # @note This operation may take some time
      # @note Use {#get_genkey_result} after {#wait} to retrieve the result
      def generate_key_pair_start(params, public_key = nil, secret_key = nil)
        # Validate parameters
        raise Crypt::GPGME::Error, "params cannot be nil" if params.nil?
        raise Crypt::GPGME::Error, "params cannot be empty" if params.to_s.empty?

        pub_ptr = public_key ? (public_key.is_a?(Data) ? public_key.instance_variable_get(:@data).pointer : public_key.pointer) : nil
        sec_ptr = secret_key ? (secret_key.is_a?(Data) ? secret_key.instance_variable_get(:@data).pointer : secret_key.pointer) : nil

        err = gpgme_op_genkey_start(@ctx.pointer, params, pub_ptr, sec_ptr)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_genkey_start failed: #{errstr}"
        end

        nil
      end

      # Signs a key with the current signing key (synchronous).
      #
      # This method creates a signature on a key, certifying that you have verified
      # the identity of the key owner. The signature is made using the signing key(s)
      # set in the context via {#add_signer}.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to sign
      # @param userid [String, nil] specific user ID to sign (nil signs all UIDs)
      # @param expires [Integer] expiration time (0 = no expiration, Unix timestamp, or relative seconds)
      # @param flags [Integer] signing flags (combination of GPGME_KEYSIGN_* constants)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Sign all user IDs on a key
      #   signing_key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.add_signer(signing_key)
      #
      #   key_to_sign = ctx.list_keys("bob@example.com").first
      #   ctx.sign_key(key_to_sign)
      #
      # @example Sign a specific user ID
      #   ctx.sign_key(key, "Bob <bob@work.com>")
      #
      # @example Create a local signature (not exportable)
      #   ctx.sign_key(key, nil, 0, Crypt::GPGME::GPGME_KEYSIGN_LOCAL)
      #
      # @example Create a signature that expires in 1 year
      #   one_year = Time.now.to_i + (365 * 24 * 60 * 60)
      #   ctx.sign_key(key, nil, one_year)
      #
      # @example Sign with no expiration and force signature
      #   flags = Crypt::GPGME::GPGME_KEYSIGN_NOEXPIRE | Crypt::GPGME::GPGME_KEYSIGN_FORCE
      #   ctx.sign_key(key, nil, 0, flags)
      #
      # @note You must set a signing key using {#add_signer} before calling this method
      # @note This operation requires the signing key's passphrase
      # @note If userid is nil, all user IDs on the key will be signed
      # @note Local signatures (GPGME_KEYSIGN_LOCAL) are not exported with the key
      # @see https://www.gnupg.org/documentation/manuals/gpgme/Signing-Keys.html
      def sign_key(key, userid = nil, expires = 0, flags = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "key cannot be nil" if key.nil?

        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_keysign(@ctx.pointer, key_struct, userid, expires, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_keysign failed: #{errstr}"
        end

        nil
      end

      # Signs a key with the current signing key (asynchronous).
      #
      # This is the asynchronous version of {#sign_key}. It initiates the
      # signing operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key to sign
      # @param userid [String, nil] specific user ID to sign (nil signs all UIDs)
      # @param expires [Integer] expiration time (0 = no expiration)
      # @param flags [Integer] signing flags (combination of GPGME_KEYSIGN_* constants)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Sign a key asynchronously
      #   signing_key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.add_signer(signing_key)
      #
      #   key_to_sign = ctx.list_keys("bob@example.com").first
      #   ctx.sign_key_start(key_to_sign)
      #   ctx.wait
      #
      # @note This operation requires the signing key's passphrase
      def sign_key_start(key, userid = nil, expires = 0, flags = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "key cannot be nil" if key.nil?

        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        err = gpgme_op_keysign_start(@ctx.pointer, key_struct, userid, expires, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_keysign_start failed: #{errstr}"
        end

        nil
      end

      # Revokes a signature on a key (synchronous).
      #
      # This method revokes a signature that was previously made on a key.
      # You can only revoke signatures that you created (signatures made with
      # your signing key).
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key with the signature to revoke
      # @param signing_key [Crypt::GPGME::Key, Structs::Key, nil] the key that made the signature (nil = current signers)
      # @param userid [String, nil] specific user ID with signature to revoke (nil revokes all)
      # @param flags [Integer] reserved for future use, should be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Revoke a signature on all user IDs
      #   signing_key = ctx.list_keys("alice@example.com", 1).first
      #   key_with_sig = ctx.list_keys("bob@example.com").first
      #   ctx.revoke_signature(key_with_sig, signing_key)
      #
      # @example Revoke signature on specific user ID
      #   ctx.revoke_signature(key, signing_key, "Bob <bob@work.com>")
      #
      # @example Revoke using current signer
      #   signing_key = ctx.list_keys("alice@example.com", 1).first
      #   ctx.add_signer(signing_key)
      #   ctx.revoke_signature(key_with_sig, nil)
      #
      # @note You must have the private key that made the original signature
      # @note This operation requires the signing key's passphrase
      # @note If userid is nil, signatures on all user IDs will be revoked
      # @note If signing_key is nil, the current signers from the context are used
      # @see https://www.gnupg.org/documentation/manuals/gpgme/Signing-Keys.html
      def revoke_signature(key, signing_key = nil, userid = nil, flags = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "key cannot be nil" if key.nil?

        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)

        # Get signing key struct, handle nil case
        signing_key_struct = if signing_key.nil?
          nil
        elsif signing_key.is_a?(Structs::Key)
          signing_key
        else
          signing_key.instance_variable_get(:@key)
        end

        err = gpgme_op_revsig(@ctx.pointer, key_struct, signing_key_struct, userid, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_revsig failed: #{errstr}"
        end

        nil
      end

      # Revokes a signature on a key (asynchronous).
      #
      # This is the asynchronous version of {#revoke_signature}. It initiates the
      # revocation operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param key [Crypt::GPGME::Key, Structs::Key] the key with the signature to revoke
      # @param signing_key [Crypt::GPGME::Key, Structs::Key, nil] the key that made the signature
      # @param userid [String, nil] specific user ID with signature to revoke (nil revokes all)
      # @param flags [Integer] reserved for future use, should be 0
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Revoke a signature asynchronously
      #   signing_key = ctx.list_keys("alice@example.com", 1).first
      #   key_with_sig = ctx.list_keys("bob@example.com").first
      #   ctx.revoke_signature_start(key_with_sig, signing_key)
      #   ctx.wait
      #
      # @note This operation requires the signing key's passphrase
      def revoke_signature_start(key, signing_key = nil, userid = nil, flags = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "key cannot be nil" if key.nil?

        key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)

        # Get signing key struct, handle nil case
        signing_key_struct = if signing_key.nil?
          nil
        elsif signing_key.is_a?(Structs::Key)
          signing_key
        else
          signing_key.instance_variable_get(:@key)
        end

        err = gpgme_op_revsig_start(@ctx.pointer, key_struct, signing_key_struct, userid, flags)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_revsig_start failed: #{errstr}"
        end

        nil
      end

      # Exports public keys to a data buffer (synchronous).
      #
      # This method exports one or more public keys in ASCII-armored format.
      # You can export by pattern (email, name, fingerprint) or export all keys.
      #
      # @param pattern [String, nil] search pattern for keys to export (nil exports all keys)
      # @param keydata [Data] Data object to receive the exported keys
      # @param mode [Integer] export mode flags (combination of GPGME_EXPORT_MODE_* constants)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Export a specific key by email
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys("alice@example.com", keydata)
      #   exported = keydata.read
      #   File.write("alice_public.asc", exported)
      #
      # @example Export all public keys
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys(nil, keydata)
      #   all_keys = keydata.read
      #
      # @example Export in minimal format (without signatures)
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys("bob@example.com", keydata, Crypt::GPGME::GPGME_EXPORT_MODE_MINIMAL)
      #
      # @example Export secret key
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys("alice@example.com", keydata, Crypt::GPGME::GPGME_EXPORT_MODE_SECRET)
      #   secret_key = keydata.read
      #
      # @example Export to SSH format
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys("alice@example.com", keydata, Crypt::GPGME::GPGME_EXPORT_MODE_SSH)
      #   ssh_key = keydata.read
      #
      # @note The pattern can be an email, name, key ID, or fingerprint
      # @note Use mode 0 for standard public key export
      # @note Secret key export requires the key's passphrase
      # @note SSH export mode is available in newer GPGME versions
      # @see https://www.gnupg.org/documentation/manuals/gpgme/Exporting-Keys.html
      def export_keys(pattern, keydata, mode = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "keydata cannot be nil" if keydata.nil?

        data_ptr = keydata.is_a?(Data) ? keydata.instance_variable_get(:@data).pointer : keydata.pointer
        err = gpgme_op_export(@ctx.pointer, pattern, mode, data_ptr)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_export failed: #{errstr}"
        end

        nil
      end

      # Exports public keys to a data buffer (asynchronous).
      #
      # This is the asynchronous version of {#export_keys}. It initiates the
      # export operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param pattern [String, nil] search pattern for keys to export (nil exports all keys)
      # @param keydata [Data] Data object to receive the exported keys
      # @param mode [Integer] export mode flags (combination of GPGME_EXPORT_MODE_* constants)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Export keys asynchronously
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys_start("alice@example.com", keydata)
      #   ctx.wait
      #   exported = keydata.read
      #
      # @note Use {#wait} to complete the operation
      def export_keys_start(pattern, keydata, mode = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "keydata cannot be nil" if keydata.nil?

        data_ptr = keydata.is_a?(Data) ? keydata.instance_variable_get(:@data).pointer : keydata.pointer
        err = gpgme_op_export_start(@ctx.pointer, pattern, mode, data_ptr)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_export_start failed: #{errstr}"
        end

        nil
      end

      # Exports keys by key objects (synchronous).
      #
      # This method exports specific keys provided as an array of Key objects.
      # More precise than pattern-based export when you already have Key objects.
      #
      # @param keys [Array<Key, Structs::Key>] array of keys to export
      # @param keydata [Data] Data object to receive the exported keys
      # @param mode [Integer] export mode flags (combination of GPGME_EXPORT_MODE_* constants)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if the operation fails
      #
      # @example Export specific keys by object
      #   keys = ctx.list_keys("alice@example.com")
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys_by_object(keys, keydata)
      #   exported = keydata.read
      #
      # @example Export multiple keys
      #   alice_keys = ctx.list_keys("alice@example.com")
      #   bob_keys = ctx.list_keys("bob@example.com")
      #   all_keys = alice_keys + bob_keys
      #
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys_by_object(all_keys, keydata)
      #
      # @example Export with minimal format
      #   keys = ctx.list_keys("alice@example.com")
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys_by_object(keys, keydata, Crypt::GPGME::GPGME_EXPORT_MODE_MINIMAL)
      #
      # @note The keys array must not be empty
      # @note Keys must exist in the keyring
      # @note More efficient than pattern matching when you have Key objects
      def export_keys_by_object(keys, keydata, mode = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "keys cannot be nil" if keys.nil?
        raise Crypt::GPGME::Error, "keys cannot be empty" if keys.empty?
        raise Crypt::GPGME::Error, "keydata cannot be nil" if keydata.nil?

        # Convert keys to array of structs and create NULL-terminated array
        key_structs = keys.map do |key|
          key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        end

        # Create a pointer array with NULL terminator
        key_array = FFI::MemoryPointer.new(:pointer, key_structs.length + 1)
        key_structs.each_with_index do |key_struct, i|
          key_array[i].put_pointer(0, key_struct)
        end
        key_array[key_structs.length].put_pointer(0, nil) # NULL terminator

        data_ptr = keydata.is_a?(Data) ? keydata.instance_variable_get(:@data).pointer : keydata.pointer
        err = gpgme_op_export_keys(@ctx.pointer, key_array, mode, data_ptr)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_export_keys failed: #{errstr}"
        end

        nil
      end

      # Exports keys by key objects (asynchronous).
      #
      # This is the asynchronous version of {#export_keys_by_object}. It initiates
      # the export operation but returns immediately without waiting for completion.
      # Use {#wait} to wait for the operation to complete.
      #
      # @param keys [Array<Key, Structs::Key>] array of keys to export
      # @param keydata [Data] Data object to receive the exported keys
      # @param mode [Integer] export mode flags (combination of GPGME_EXPORT_MODE_* constants)
      # @return [void]
      # @raise [Crypt::GPGME::Error] if starting the operation fails
      #
      # @example Export keys asynchronously
      #   keys = ctx.list_keys("alice@example.com")
      #   keydata = Crypt::GPGME::Data.new
      #   ctx.export_keys_by_object_start(keys, keydata)
      #   ctx.wait
      #   exported = keydata.read
      #
      # @note Use {#wait} to complete the operation
      def export_keys_by_object_start(keys, keydata, mode = 0)
        # Validate parameters
        raise Crypt::GPGME::Error, "keys cannot be nil" if keys.nil?
        raise Crypt::GPGME::Error, "keys cannot be empty" if keys.empty?
        raise Crypt::GPGME::Error, "keydata cannot be nil" if keydata.nil?

        # Convert keys to array of structs and create NULL-terminated array
        key_structs = keys.map do |key|
          key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
        end

        # Create a pointer array with NULL terminator
        key_array = FFI::MemoryPointer.new(:pointer, key_structs.length + 1)
        key_structs.each_with_index do |key_struct, i|
          key_array[i].put_pointer(0, key_struct)
        end
        key_array[key_structs.length].put_pointer(0, nil) # NULL terminator

        data_ptr = keydata.is_a?(Data) ? keydata.instance_variable_get(:@data).pointer : keydata.pointer
        err = gpgme_op_export_keys_start(@ctx.pointer, key_array, mode, data_ptr)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_export_keys_start failed: #{errstr}"
        end

        nil
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
