require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Context
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

      def initialize
        @ctx = Crypt::GPGME::Structs::Context.new
        err = gpgme_new(@ctx)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_new failed: #{errstr}"
        end
      end

      def get_engine_info
        ptr = gpgme_ctx_get_engine_info(@ctx)
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

          info = EngineInfo.new(info[:next])
        end

        arr
      end

      def set_engine_info(proto, file_name, home_dir)
        gpgme_ctx_set_engine_info(@ctx, proto, file_name, home_dir)
      end

      def protocol
        gpgme_get_protocol(@ctx)
      end

      def protocol=(proto)
        err = gpgme_set_protocol(@ctx, proto)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_set_protocol failed: #{errstr}"
        end
      end

      def release
        gpgme_release(@ctx)
      end
    end
  end
end
