require 'forwardable'
require_relative 'subkey'
require_relative 'user_id'
require_relative 'revocation_key'

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
        elsif obj.is_a?(FFI::MemoryPointer)
          @key = Crypt::GPGME::Structs::Key.new(obj)
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
        return subkey_array if subkey.null?

        subkey_array << Crypt::GPGME::Subkey.new(subkey)

        loop do
          subkey = Crypt::GPGME::Structs::Subkey.new(subkey[:next])
          break if subkey.null?
          subkey_array << Crypt::GPGME::Subkey.new(subkey)
        end

        subkey_array
      end

      def uids
        uid_array = []
        uid = @key[:uids]
        return uid_array if uid.null?

        uid_array << Crypt::GPGME::UserId.new(uid)

        loop do
          uid = Crypt::GPGME::Structs::UserId.new(uid[:next])
          break if uid.null?
          uid_array << Crypt::GPGME::UserId.new(uid)
        end

        uid_array
      end

      alias users uids

      def revocation_keys
        revkey_array = []
        revkey = @key[:revocation_keys]
        return revkey_array if revkey.null?

        revkey_array << Crypt::GPGME::RevocationKey.new(revkey)

        loop do
          revkey = Crypt::GPGME::Structs::RevocationKey.new(revkey[:next])
          break if revkey.null?
          revkey_array << Crypt::GPGME::RevocationKey.new(revkey)
        end

        revkey_array
      end
    end
  end
end
