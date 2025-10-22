require 'forwardable'

module Crypt
  class GPGME
    class RevocationKey
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@revkey, :sensitive?

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(RevocationKey)

        if obj.is_a?(Crypt::GPGME::Structs::RevocationKey)
          @revkey = obj
        elsif obj.is_a?(FFI::MemoryPointer)
          @revkey = Crypt::GPGME::Structs::RevocationKey.new(obj)
        else
          @revkey = Crypt::GPGME::Structs::RevocationKey.new
        end
      end

      def object
        @revkey
      end

      def to_hash
        @revkey.to_hash
      end

      def pubkey_algo
        @revkey[:pubkey_algo]
      end

      def fpr
        @revkey[:fpr]
      end

      def key_class
        @revkey[:key_class]
      end
    end
  end
end
