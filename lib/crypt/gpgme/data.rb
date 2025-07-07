module Crypt
  class GPGME
    class Data
      include Crypt::GPGME::Constants
      include Crypt::GPGME::Functions

      attr_accessor :buffer_size

      def initialize(obj)
        @buffer_size = 4096

        return if obj.nil?
        return obj if obj.is_a?(Data)

        if obj.is_a?(Crypt::GPGME::Structs::Data)
          @data = obj
        else
          @data = Crypt::GPGME::Structs::Data.new
        end

        err = gpgme_data_new(@data)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new failed: #{errstr}"
        end

        @object = obj

        if obj.is_a?(Numeric) || obj.respond_to?(:fileno)
          from_fd
        elsif obj.is_a?(String) && File.extname(obj).size > 0
          from_file
        elsif obj.respond_to?(:to_str)
          from_str
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

      def close
        gpgme_data_release(@data.dh)
      end

      private

      def from_fd
        fd = @object.respond_to?(:fileno) ? @object.fileno : @object
        err = gpgme_data_new_from_fd(@data.pointer, fd)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new_from_fd failed: #{errstr}"
        end
      end

      def from_str
        err = gpgme_data_new_from_mem(@data.pointer, @object, @object.bytesize, 0)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new_from_mem failed: #{errstr}"
        end
      end

      def from_file
        err = gpgme_data_new_from_file(@data.pointer, @object, 0)

        if err != GPG_ERR_NO_ERROR
          errstr = gpgme_strerror(err)
          raise Crypt::GPGME::Error, "gpgme_data_new_from_file failed: #{errstr}"
        end
      end
    end
  end
end
