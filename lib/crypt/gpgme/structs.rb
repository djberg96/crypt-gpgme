require 'ffi'

module Crypt
  class GPGME
    module Structs
      class EngineInfo < FFI::Struct
        layout(
          :next, :pointer,
          :protocol, :uint,
          :file_name, :string,
          :home_dir, :string,
          :version, :string,
          :req_version, :string
        )
      end
    end
  end
end
