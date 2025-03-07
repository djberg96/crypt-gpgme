require 'ffi'

module Crypt
  class GPGME
    module Functions
      extend FFI::Library
      ffi_lib :gpgme

      attach_function :gpgme_check_version, [:string], :string
      attach_function :gpgme_set_global_flag, [:string, :string], :int
    end
  end
end
