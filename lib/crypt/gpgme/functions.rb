require 'ffi'
require_relative 'structs'

module Crypt
  class GPGME
    module Functions
      extend FFI::Library
      ffi_lib :gpgme

      attach_function :gpgme_check_version, [:string], :string
      attach_function :gpgme_engine_check_version, [:int], :int
      attach_function :gpgme_get_engine_info, [:pointer], :int
      attach_function :gpgme_get_dirinfo, [:string], :string
      attach_function :gpgme_set_global_flag, [:string, :string], :int
    end
  end
end
