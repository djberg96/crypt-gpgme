require 'forwardable'

module Crypt
  class GPGME
    class KeySignature
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@keysig, :revoked?, :expired?, :invalid?,
        :exportable?, :trust_depth, :trust_value

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(KeySignature)

        if obj.is_a?(Crypt::GPGME::Structs::KeySignature)
          @keysig = obj
        elsif obj.is_a?(FFI::MemoryPointer)
          @keysig = Crypt::GPGME::Structs::KeySignature.new(obj)
        else
          @keysig = Crypt::GPGME::Structs::KeySignature.new
        end
      end

      def object
        @keysig
      end

      def to_hash
        @keysig.to_hash
      end

      def pubkey_algo
        @keysig[:pubkey_algo]
      end

      def keyid
        @keysig[:keyid]
      end

      def timestamp
        @keysig[:timestamp]
      end

      def expires
        @keysig[:expires]
      end

      def status
        @keysig[:status]
      end

      def uid
        @keysig[:uid]
      end

      def name
        @keysig[:name]
      end

      def email
        @keysig[:email]
      end

      def comment
        @keysig[:comment]
      end

      def sig_class
        @keysig[:sig_class]
      end

      def notations
        @keysig[:notations]
      end

      def trust_scope
        @keysig[:trust_scope]
      end
    end
  end
end
