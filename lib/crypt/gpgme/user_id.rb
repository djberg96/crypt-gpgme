require 'forwardable'
require_relative 'key_signature'

module Crypt
  class GPGME
    class UserId
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@userid, :revoked?, :invalid?

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(UserId)

        if obj.is_a?(Crypt::GPGME::Structs::UserId)
          @userid = obj
        elsif obj.is_a?(FFI::MemoryPointer)
          @userid = Crypt::GPGME::Structs::UserId.new(obj)
        else
          @userid = Crypt::GPGME::Structs::UserId.new
        end
      end

      def object
        @userid
      end

      def to_hash
        @userid.to_hash
      end

      def validity
        @userid[:validity]
      end

      def uid
        @userid[:uid]
      end

      def name
        @userid[:name]
      end

      def email
        @userid[:email]
      end

      def comment
        @userid[:comment]
      end

      def address
        @userid[:address]
      end

      def tofu
        @userid[:tofu]
      end

      def last_update
        @userid[:last_update]
      end

      def uidhash
        @userid[:uidhash]
      end

      def signatures
        signature_array = []
        signature = @key[:subkeys]
        signature_array << signature

        loop do
          signature = Crypt::GPGME::Structs::KeySig.new(signature[:next])
          break if signature.null?
          signature_array << Crypt::GPGME::KeySignature.new(signature)
        end

        signature_array
      end
    end
  end
end
