require 'ffi'
require_relative 'constants'

module Crypt
  class GPGME
    module Structs
      extend FFI::Library
      include Crypt::GPGME::Constants

      class EngineInfo < FFI::Struct
        layout(
          :next, :pointer,
          :protocol, :uint,
          :file_name, :string,
          :version, :string,
          :req_version, :string,
          :home_dir, :string
        )
      end
    end
  end
end
