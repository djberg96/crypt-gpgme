require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Engine
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Crypt::GPGME::Constants
      extend Crypt::GPGME::Functions
      extend Crypt::GPGME::Structs

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(Engine)

        if obj.is_a?(Crypt::GPGME::Structs::EngineInfo)
          @engine = obj
        else
          @engine = Crypt::GPGME::Structs::EngineInfo.new
        end
      end

      def object
        @engine
      end

      def to_hash
        @engine.to_hash
      end

      def protocol(type: 'numeric')
        if type.to_s == 'string'
          gpgme_get_protocol_name(@engine[:protocol])
        else
          @engine[:protocol]
        end
      end

      def file_name
        @engine[:file_name]
      end

      def version
        @engine[:version]
      end

      def req_version
        @engine[:req_version]
      end

      def home_dir
        @engine[:home_dir]
      end

      class << self
        # Verifies that the engine implementing the +protocol+ is installed
        # in the expected path and meets the version requirement of GPGME.
        # Returns true if verified, false otherwise.
        #
        def check_version(protocol = GPGME_PROTOCOL_OPENPGP)
          gpgme_engine_check_version(protocol) == GPG_ERR_NO_ERROR
        end

        # Returns a string for the associated value of +what+, or nil if no value
        # is found. Uses 'homedir' by default.
        #
        # Examples:
        #
        #   puts Crypt::GPGME::Engine.dir_info
        #   puts Crypt::GPGME::Engine.dir_info("datadir")
        #
        def dir_info(what = 'homedir')
          gpgme_get_dirinfo(what)
        end

        # Returns an array of hash information about supported protocols
        # on your platform. The hash includes the protocol name, home
        # directory, version and required version.
        #
        def get_info
          info = EngineInfo.new
          err = gpgme_get_engine_info(info)

          if err != GPG_ERR_NO_ERROR
            raise SystemCallError.new('gpgme_get_engine_info', err)
          end

          arr = []

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

        # Change the configuration of a backend engine, and thus change the
        # executable program and configuration directory to be used.
        #
        # You can make these changes the default or set them for some
        # contexts individually.
        #
        # NOTE: In practice you will typically want to set this at the
        # context level to avoid contaminating the global GPG status if
        # there are several GPG processes running simultaneously.
        #
        # See Context#set_engine_info.
        #
        def set_info(protocol, file_name, home_dir)
          rv = gpgme_set_engine_info(protocol, file_name, home_dir)
          raise SystemCallError.new('gpgme_set_engine_info', rv) if rv != GPG_ERR_NO_ERROR
          true
        end
      end
    end
  end
end
