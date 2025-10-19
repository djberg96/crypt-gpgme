require_relative 'constants'
require_relative 'functions'
require_relative 'structs'
require_relative 'key'

module Crypt
  class GPGME
    class Context
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

      def initialize
        @ctx = Structs::Context.new
        @released = false

        gpgme_check_version(nil)
        err = gpgme_new(@ctx)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_new failed: #{errstr}"
        end

        yield self if block_given?
      end

      def armor=(bool)
        gpgme_set_armor(@ctx.pointer, bool)
      end

      def armor?
        gpgme_get_armor(@ctx.pointer)
      end

      def get_flag(name)
        gpgme_get_ctx_flag(@ctx.pointer, name)
      end

      def set_flag(name, value)
        err = gpme_set_ctx_flag(@ctx.pointer, name, value)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_ctx_flag failed: #{errstr}"
        end

        {name => value}
      end

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

      def get_key(fingerprint, secret = true)
        key = FFI::MemoryPointer.new(:pointer)
        err = gpgme_get_key(@ctx.pointer, fingerprint, key, secret)

        if err == GPG_ERR_NO_ERROR
          key = Crypt::GPGME::Structs::Key.new(key.read_pointer)
        else
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_get_key failed: #{errstr}"
        end

        Crypt::GPGME::Key.new(key)
      end

      def set_engine_info(proto, file_name, home_dir)
        gpgme_ctx_set_engine_info(@ctx.pointer, proto, file_name, home_dir)
      end

      def include_certs
        gpgme_get_include_certs(@ctx.pointer)
      end

      def include_certs=(num)
        gpgme_set_include_certs(@ctx.pointer, num)
      end

      def keylist_mode(type: 'numeric')
        mode = gpgme_get_keylist_mode(@ctx.pointer)

        return mode if type.to_s == 'numeric'

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

      def keylist_mode=(mode)
        err = gpgme_set_keylist_mode(@ctx.pointer, mode)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_keylist_mode failed: #{errstr}"
        end

        mode
      end

      def set_locale(category, value)
        err = gpgme_set_locale(@ctx.pointer, category, value)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_locale failed: #{errstr}"
        end

        {category => value}
      end

      def set_tofu_policy(key, value)
        err = gpgme_op_tofu_policy(@ctx.pointer, key, value)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_tofu_policy failed: #{errstr}"
        end

        value
      end

      def protocol
        gpgme_get_protocol(@ctx.pointer)
      end

      def protocol=(proto)
        err = gpgme_set_protocol(@ctx.pointer, proto)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_protocol failed: #{errstr}"
        end
      end

      def offline?
        gpgme_get_offline(@ctx.pointer)
      end

      def offline=(bool)
        gpgme_set_offline(@ctx.pointer, bool)
      end

      def pinentry_mode(type: 'numeric')
        mode = gpgme_get_pinentry_mode(@ctx.pointer)

        return mode if type.to_s == 'numeric'

        flags = []
        flags << 'GPGME_PINENTRY_MODE_DEFAULT' if (mode & GPGME_PINENTRY_MODE_DEFAULT) != 0
        flags << 'GPGME_PINENTRY_MODE_ASK' if (mode & GPGME_PINENTRY_MODE_ASK) != 0
        flags << 'GPGME_PINENTRY_MODE_CANCEL' if (mode & GPGME_PINENTRY_MODE_CANCEL) != 0
        flags << 'GPGME_PINENTRY_MODE_ERROR' if (mode & GPGME_PINENTRY_MODE_ERROR) != 0
        flags << 'GPGME_PINENTRY_MODE_LOOPBACK' if (mode & GPGME_PINENTRY_MODE_LOOPBACK) != 0

        flags.empty? ? 'NONE' : flags.join(' | ')
      end

      def pinentry_mode=(mode)
        gpgme_set_pinentry_mode(@ctx.pointer, mode)
      end

      def sign(data, sig = Crypt::GPGME::Structs::KeySig.new, mode = GPGME_SIG_MODE_NORMAL)
        err = gpgme_op_sign(@ctx.pointer, data, sig, mode)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_sign failed: #{errstr}"
        end

        sig
      end

      def text_mode?
        gpgme_get_textmode(@ctx.pointer)
      end

      def text_mode=(bool)
        gpgme_set_textmode(@ctx.pointer, bool)
      end

      def release
        return if @released

        if !@ctx.pointer.null?
          gpgme_release(@ctx.pointer)
          @released = true
        end
      end

      def released?
        @released
      end

      def list_keys(pattern: nil, secret: 0)
        if pattern.is_a?(Array)
          pattern_ptrs = FFI::MemoryPointer.new(:pointer, pattern.length)

          pattern.each_with_index do |str, i|
            pattern_ptrs[i].put_pointer(0, FFI::MemoryPointer.from_string(str))
          end

          err = gpgme_op_keylist_ext_start(@ctx.pointer, pattern_ptrs, secret, 0)
        else
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
          arr << Crypt::GPGME::Key.new(key)
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
  require 'pp'
  ctx = Crypt::GPGME::Context.new
  #pp ctx.list_keys(pattern: ['bdunne', 'djberg96'], type: 'object')
  key = pp ctx.list_keys(pattern: ['djberg96']).first
  #pp ctx.list_keys(pattern: 'djberg96', type: 'hash')
  #pp ctx.list_keys(pattern: ['djberg96', type: 'hash')
  #pp ctx.keylist_mode(format: :numeric)
  #pp ctx.keylist_mode(format: :string)
  #pp ctx.pinentry_mode(type: 'string')
  #pp key.to_hash
  pp key.subkeys
  pp key.uids
end
