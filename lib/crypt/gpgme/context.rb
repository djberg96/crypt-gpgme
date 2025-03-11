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

      def release
        gpgme_release(@ctx)
      end
    end
  end
end
