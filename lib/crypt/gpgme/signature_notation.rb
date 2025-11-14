require 'forwardable'

module Crypt
  class GPGME
    class SignatureNotation
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@notation, :name, :value, :flags, :critical?, :human_readable?

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(Key)

        if obj.is_a?(Crypt::GPGME::Structs::SigNotation)
          @notation = obj
        elsif obj.is_a?(FFI::MemoryPointer)
          @notation = Crypt::GPGME::Structs::SigNotation.new(obj)
        else
          @notation = Crypt::GPGME::Structs::SigNotation.new
        end
      end

      def object
        @notation
      end

      def to_hash
        @notation.to_hash
      end
    end
  end
end
