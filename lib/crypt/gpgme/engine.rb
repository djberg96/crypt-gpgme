require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Engine
      include Crypt::GPGME::Constants
      extend Crypt::GPGME::Constants
      extend Crypt::GPGME::Functions
      extend Crypt::GPGME::Structs

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

        def info
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
      end
    end
  end
end
