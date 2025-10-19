require 'forwardable'
require_relative 'subkey'

module Crypt
  class GPGME
    class Key
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@key, :revoked?, :expired?, :disabled?, :invalid?,
        :can_encrypt?, :can_sign?, :can_certify?, :secret?, :can_authenticate?,
        :is_qualified?, :has_encrypt?, :has_sign?, :has_certify?, :has_authenticate?

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(Key)

        if obj.is_a?(Crypt::GPGME::Structs::Key)
          @key = obj
        else
          @key = Crypt::GPGME::Structs::Key.new
        end
      end

      def object
        @key
      end

      def to_hash
        @key.to_hash
      end

      def chain_id
        @key[:chain_id]
      end

      def owner_trust
        @key[:owner_trust]
      end

      def protocol
        @key[:protocol]
      end

      def issuer_serial
        @key[:issuer_serial]
      end

      def issuer_name
        @key[:issuer_name]
      end

      def keylist_mode
        @key[:keylist_mode]
      end

      def fpr
        @key[:fpr]
      end

      alias fingerprint fpr

      def last_update
        @key[:last_update]
      end

      def subkeys
        subkey_array = []
        subkey = @key[:subkeys]
        subkey_array << subkey

        loop do
          subkey = Crypt::GPGME::Structs::Subkey.new(subkey[:next])
          break if subkey.null?
          subkey_array << Crypt::GPGME::Subkey.new(subkey)
        end

        subkey_array
      end

      def uids
        @key[:uids]
      end

      def revocation_keys
        @key[:revocation_keys]
      end

      alias users uids
    end
  end
end
