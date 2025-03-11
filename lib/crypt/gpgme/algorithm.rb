require_relative 'constants'
require_relative 'functions'
require_relative 'structs'

module Crypt
  class GPGME
    class Algorithm
      include Crypt::GPGME::Constants
      extend Crypt::GPGME::Constants
      extend Crypt::GPGME::Functions
      extend Crypt::GPGME::Structs

      class << self
        # Returns a string containing a description of the public key +algorithm+.
        #
        def pubkey_algorithm_name(algorithm)
          gpgme_pubkey_algo_name(algorithm)
        end

        # Returns a string containing a description of the hash +algorithm+.
        #
        def hash_algorithm_name(algorithm)
          gpgme_hash_algo_name(algorithm)
        end

        # Returns the name of the algorithm used by +subkey+.
        #
        def pubkey_algorithm_string(subkey)
          gpgme_pubkey_algo_string(subkey)
        end
      end
    end
  end
end
