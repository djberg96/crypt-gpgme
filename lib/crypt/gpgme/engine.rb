require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Engine
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Crypt::GPGME::Functions

      def check_version
        #gpgme_engine_check_version
      end

      def dir_info(what = 'homedir')
        gpgme_get_dirinfo(what)
      end
    end
  end
end
