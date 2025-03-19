require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Context
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

      def initialize
        @ctx = Structs::Context.new
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

      def set_engine_info(proto, file_name, home_dir)
        gpgme_ctx_set_engine_info(@ctx.pointer, proto, file_name, home_dir)
      end

      def include_certs
        gpgme_get_include_certs(@ctx.pointer)
      end

      def include_certs=(num)
        gpgme_set_include_certs(@ctx.pointer, num)
      end

      def keylist_mode
        gpgme_get_keylist_mode(@ctx.pointer)
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

      def pinentry_mode
        gpgme_get_pinentry_mode(@ctx.pointer)
      end

      def pinentry_mode=(mode)
        gpgme_set_pinentry_mode(@ctx.pointer, mode)
      end

      def text_mode?
        gpgme_get_textmode(@ctx.pointer)
      end

      def text_mode=(bool)
        gpgme_set_textmode(@ctx.pointer, bool)
      end

      def release
        gpgme_release(@ctx.pointer) if !@ctx.pointer.null?
      end

      def list_keys(pattern = nil, secret = 0)
        err = gpgme_op_keylist_start(@ctx.pointer, pattern, secret)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_op_keylist_start failed: #{errstr}"
        end

        arr = []

        while err == GPG_ERR_NO_ERROR
          key = Structs::Key.new
          err = gpgme_op_keylist_next(@ctx.pointer, key)
          break if err != GPG_ERR_NO_ERROR
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
