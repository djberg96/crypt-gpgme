module Crypt
  class GPGME
    class Data
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

      attr_accessor :buffer_size

      def initialize(obj)
        @buffer_size = 4096

        return if obj.nil?
        return obj if obj.is_a?(Crypt::GPGME::Structs::Data)
        return obj if obj.is_a?(Data)

        @data = Crypt::GPGME::Structs::Data.new
        err = gpgme_data_new(@data)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new failed: #{errstr}"
        end

        @obj = obj

        if obj.is_a?(Numeric)
          from_fd
        elsif obj.respond_to?(:to_str)
          from_str
        else
          from_io
        end
      end

      private

      def from_fd
      end

      def from_str
        err = gpgme_data_new_from_mem(@data.pointer, @obj, @obj.bytesize, 0)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new_from_mem failed: #{errstr}"
        end
      end

      def from_io
      end
    end
  end
end
