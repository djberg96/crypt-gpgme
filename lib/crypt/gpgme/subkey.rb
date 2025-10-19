require 'forwardable'

module Crypt
  class GPGME
    class Subkey
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions
      extend Forwardable

      def_delegators :@subkey, :revoked?, :expired?, :disabled?, :invalid?,
        :can_encrypt?, :can_sign?, :can_certify?, :secret?, :can_authenticate?,
        :is_qualified?, :is_cardkey?, :is_de_vs?, :can_renc?, :can_timestamp?,
        :is_group_owned?, :beta_compliance?

      def initialize(obj)
        return if obj.nil?
        return obj if obj.is_a?(Key)

        if obj.is_a?(Crypt::GPGME::Structs::Subkey)
          @subkey = obj
        else
          @subkey = Crypt::GPGME::Structs::Subkey.new
        end
      end

      def object
        @subkey
      end

      def to_hash
        @subkey.to_hash
      end

      def pubkey_algo
        @subkey[:pubkey_algo]
      end

      alias pubkey_algo pubkey_algorithm

      def length
        @subkey[:length]
      end

      def fpr
        @subkey[:fpr]
      end

      alias fpr fingerprint

      def timestamp
        @subkey[:timestamp]
      end

      def expires
        @subkey[:expires]
      end

      def card_number
        @subkey[:card_number]
      end

      def curve
        @subkey[:curve]
      end

      def keygrip
        @subkey[:keygrip]
      end

      def v5fpr
        @subkey[:v5fpr]
      end
    end
  end
end
