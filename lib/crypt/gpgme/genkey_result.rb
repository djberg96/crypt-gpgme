require 'forwardable'
require_relative 'subkey'
require_relative 'user_id'
require_relative 'revocation_key'

module Crypt
  class GPGME
    class GenkeyResult
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@key_result, :primary?, :sub?, :uid

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(Key)

        if obj.is_a?(Crypt::GPGME::Structs::GenkeyResult)
          @key_result = obj
        elsif obj.is_a?(FFI::Pointer)
          gpgme_result_ref(obj)
          ObjectSpace.define_finalizer(self, self.class.finalize(obj))
          @key_result = Crypt::GPGME::Structs::GenkeyResult.new(obj)
        else
          @key_result = Crypt::GPGME::Structs::GenkeyResult.new(obj)
        end
      end

      def self.finalize(obj)
        proc{ gpgme_result_unref(obj) }
      end

      def object
        @key_result
      end

      def to_hash
        @key_result.to_hash
      end

      def fpr
        @key_result[:fpr]
      end

      alias fingerprint fpr

      def pubkey
        @key_result[:pubkey]
      end

      def seckey
        @key_result[:seckey]
      end
    end
  end
end
