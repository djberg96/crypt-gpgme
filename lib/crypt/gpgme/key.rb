module Crypt
  class GPGME
    class Key
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

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

      def protocol
        @key[:protocol]
      end

      def issuer_serial
        @key[:issuer_serial]
      end

      def keylist_mode
        @key[:keylist_mode]
      end
    end
  end
end
