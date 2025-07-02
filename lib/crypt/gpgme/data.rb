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

        @object = obj

        if obj.is_a?(Numeric)
          from_fd
        elsif obj.respond_to?(:to_str)
          from_str
        else
          from_io
        end
      end

      def read(size = 4096)
        buf = FFI::MemoryPointer.new(:char, size)
        err = gpgme_data_read(@data.dh, buf, buf.size)

        if err == -1
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_read failed: #{errstr}"
        end

        buf.read_string
      end

      def rewind
        offset = gpgme_data_seek(@data.dh, 0, IO::SEEK_SET)

        raise Crypt::GPGME::Error, "gpgme_data_seek failed" if offset == -1

        true
      end

      def to_s
        rewind
        read
      end

      private

      def from_fd
      end

      def from_str
        err = gpgme_data_new_from_mem(@data.pointer, @object, @object.bytesize, 0)

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
