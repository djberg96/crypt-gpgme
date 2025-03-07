require_relative 'gpgme/constants'
require_relative 'gpgme/functions'
require_relative 'gpgme/context'

module Crypt
  class GPGME
    include Crypt::GPGME::Constants
    include Crypt::GPGME::Functions
    extend Crypt::GPGME::Functions

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
    end
  end
end

p Crypt::GPGME.new
