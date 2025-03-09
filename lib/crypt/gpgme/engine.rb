require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Engine
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Crypt::GPGME::Functions

      class << self
        def check_version
          #gpgme_engine_check_version
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
      end
    end
  end
end
