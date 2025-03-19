require 'ffi'
require_relative 'structs'

module Crypt
  class GPGME
    module Functions
      extend FFI::Library
      ffi_lib :gpgme

      attach_function :gpgme_check_version, [:string], :string
      attach_function :gpgme_ctx_get_engine_info, [Structs::Context], Structs::EngineInfo
      attach_function :gpgme_ctx_set_engine_info, [Structs::Context, :uint, :string, :string], :int
      attach_function :gpgme_engine_check_version, [:int], :int
      attach_function :gpgme_get_armor, [Structs::Context], :bool
      attach_function :gpgme_get_ctx_flag, [Structs::Context, :string], :string
      attach_function :gpgme_get_engine_info, [Structs::EngineInfo], :int
      attach_function :gpgme_get_dirinfo, [:string], :string
      attach_function :gpgme_get_key, [:pointer, :string, :pointer, :int], :uint
      attach_function :gpgme_get_include_certs, [:pointer], :int
      attach_function :gpgme_get_keylist_mode, [:pointer], :uint
      attach_function :gpgme_get_offline, [Structs::Context], :bool
      attach_function :gpgme_get_pinentry_mode, [Structs::Context], :uint
      attach_function :gpgme_get_protocol, [Structs::Context], :uint
      attach_function :gpgme_get_protocol_name, [:uint], :string
      attach_function :gpgme_get_textmode, [Structs::Context], :bool
      attach_function :gpgme_hash_algo_name, [:uint], :string
      attach_function :gpgme_new, [Structs::Context], :uint
      attach_function :gpgme_op_keylist_start, [:pointer, :string, :int], :uint
      attach_function :gpgme_op_keylist_end, [:pointer], :uint
      attach_function :gpgme_op_keylist_ext_start, [:pointer, :pointer, :int, :int], :uint
      attach_function :gpgme_op_keylist_from_data_start, [:pointer, :pointer, :int], :uint
      attach_function :gpgme_op_keylist_next, [:pointer, :pointer], :uint
      attach_function :gpgme_op_keylist_result, [:pointer], :uint
      attach_function :gpgme_pubkey_algo_name, [:uint], :string
      attach_function :gpgme_pubkey_algo_string, [:pointer], :string
      attach_function :gpgme_release, [:pointer], :void
      attach_function :gpgme_set_armor, [:pointer, :bool], :void
      attach_function :gpgme_set_ctx_flag, [Structs::Context, :string, :string], :uint
      attach_function :gpgme_set_engine_info, [:uint, :string, :string], :int
      attach_function :gpgme_set_global_flag, [:string, :string], :int
      attach_function :gpgme_set_include_certs, [:pointer, :int], :void
      attach_function :gpgme_set_keylist_mode, [:pointer, :int], :uint
      attach_function :gpgme_set_locale, [:pointer, :int, :string], :uint
      attach_function :gpgme_set_offline, [Structs::Context, :bool], :void
      attach_function :gpgme_set_pinentry_mode, [Structs::Context, :uint], :uint
      attach_function :gpgme_set_protocol, [Structs::Context, :uint], :uint
      attach_function :gpgme_set_textmode, [Structs::Context, :bool], :void
      attach_function :gpgme_strerror, [:uint], :string
      attach_function :gpgme_strerror_r, [:uint, :buffer_in, :size_t], :uint
      attach_function :gpgme_strsource, [:uint], :string
    end
  end
end
