require_relative 'gpgme/constants'
require_relative 'gpgme/functions'
require_relative 'gpgme/context'

module Crypt
  class GPGME
    include Crypt::GPGME::Constants
    include Crypt::GPGME::Functions
    extend Crypt::GPGME::Functions

    class Error < StandardError; end

    def initialize
      gpgme_check_version(nil) # Initialize subsystems
    end

    class << self
      # Return the version number for the gpgme library.
      #
      # If the +required+ parameter is not nil, the method checks that the
      # version of the gpgme library is at least as high as the version number
      # provided. If it is not, then nil is returned instead.
      #
      # Note that this method also invokes some subsystems, and should be
      # invoked first before using other gpgme methods.
      #
      def check_version(required = nil)
        gpgme_check_version(required)
      end

      # Set a global flag. The possible flags are:
      #
      # * debug
      # * disable-gpgconf
      # * gpg-name (or gpgconf-name)
      # * require-gnupg
      # * inst-type
      # * w32-inst-dir
      #
      # Example:
      #
      #   Crypt::GPGME.set_global_flag("debug", "9:/Users/your_userid/mygpgme.log")
      #
      def set_global_flag(key, value)
        if gpgme_set_global_flag(key, value) != 0
          raise Error, "gpgme_set_global_flag failed"
        end
      end
    end
  end
end

p Crypt::GPGME.set_global_flag("debug", "9:/Users/daniel.berger/mygpgme.log")
p Crypt::GPGME.check_version
