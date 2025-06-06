require 'ffi'
require_relative 'structs'

module Crypt
  class GPGME
    module Functions
      extend FFI::Library

      ffi_lib :gpgme

      typedef :uint, :gpgme_error_t
      typedef :uint, :gpgme_data_t

      attach_function :gpgme_check_version, [:string], :string
      attach_function :gpgme_ctx_get_engine_info, [Structs::Context], Structs::EngineInfo
      attach_function :gpgme_ctx_set_engine_info, [Structs::Context, :uint, :string, :string], :int
      attach_function :gpgme_engine_check_version, [:int], :int
      attach_function :gpgme_get_armor, [Structs::Context], :bool
      attach_function :gpgme_get_ctx_flag, [Structs::Context, :string], :string
      attach_function :gpgme_get_engine_info, [Structs::EngineInfo], :int
      attach_function :gpgme_get_dirinfo, [:string], :string
      attach_function :gpgme_get_include_certs, [Structs::Context], :int
      attach_function :gpgme_get_key, [Structs::Context, :string, :pointer, :bool], :uint
      attach_function :gpgme_get_keylist_mode, [Structs::Context], :uint
      attach_function :gpgme_get_offline, [Structs::Context], :bool
      attach_function :gpgme_get_pinentry_mode, [Structs::Context], :uint
      attach_function :gpgme_get_protocol, [Structs::Context], :uint
      attach_function :gpgme_get_protocol_name, [:uint], :string
      attach_function :gpgme_get_sender, [Structs::Context], :string
      attach_function :gpgme_get_textmode, [Structs::Context], :bool
      attach_function :gpgme_hash_algo_name, [:uint], :string
      attach_function :gpgme_key_ref, [Structs::Key], :void
      attach_function :gpgme_key_unref, [Structs::Key], :void
      attach_function :gpgme_new, [Structs::Context], :uint
      attach_function :gpgme_op_adduid, [Structs::Context, Structs::Key, :string, :uint], :uint
      attach_function :gpgme_op_adduid_start, [Structs::Context, Structs::Key, :string, :uint], :uint
      attach_function :gpgme_op_createkey, [Structs::Context, :string, :string, :uint, :uint, Structs::Key, :uint], :uint
      attach_function :gpgme_op_createkey_start, [Structs::Context, :string, :string, :uint, :uint, Structs::Key, :uint], :uint
      attach_function :gpgme_op_createsubkey, [Structs::Context, Structs::Key, :string, :uint, :uint, :uint], :uint
      attach_function :gpgme_op_createsubkey_start, [Structs::Context, Structs::Key, :string, :uint, :uint, :uint], :uint
      attach_function :gpgme_op_export, [Structs::Context, :string, :uint, :pointer], :uint
      attach_function :gpgme_op_export_start, [Structs::Context, :string, :uint, :pointer], :uint
      attach_function :gpgme_op_export_ext, [Structs::Context, :string, :uint, :pointer], :uint
      attach_function :gpgme_op_export_ext_start, [Structs::Context, :string, :uint, :pointer], :uint
      attach_function :gpgme_op_export_keys, [Structs::Context, :pointer, :uint, :pointer], :uint
      attach_function :gpgme_op_export_keys_start, [Structs::Context, :pointer, :uint, :pointer], :uint
      attach_function :gpgme_op_getauditlog, [Structs::Context, :pointer, :uint], :uint
      attach_function :gpgme_op_genkey, [Structs::Context, :string, :pointer, :pointer], :uint
      attach_function :gpgme_op_genkey_result, [Structs::Context], :pointer
      attach_function :gpgme_op_genkey_start, [Structs::Context, :string, :pointer, :pointer], :uint
      attach_function :gpgme_op_getauditlog_start, [Structs::Context, :pointer, :uint], :uint
      attach_function :gpgme_op_import, [Structs::Context, :gpgme_data_t], :gpgme_error_t
      attach_function :gpgme_op_import_start, [Structs::Context, :gpgme_data_t], :gpgme_error_t
      attach_function :gpgme_op_import_keys, [Structs::Context, :pointer], :gpgme_error_t
      attach_function :gpgme_op_import_keys_start, [Structs::Context, :pointer], :gpgme_error_t
      attach_function :gpgme_op_import_result, [Structs::Context], :pointer
      attach_function :gpgme_op_keylist_start, [Structs::Context, :string, :int], :uint
      attach_function :gpgme_op_keylist_end, [Structs::Context], :uint
      attach_function :gpgme_op_keylist_ext_start, [Structs::Context, :pointer, :int, :int], :uint
      attach_function :gpgme_op_keylist_from_data_start, [Structs::Context, :pointer, :int], :uint
      attach_function :gpgme_op_keylist_next, [Structs::Context, :pointer], :uint
      attach_function :gpgme_op_keylist_result, [Structs::Context], Structs::KeylistResult.by_value
      attach_function :gpgme_op_keysign, [Structs::Context, Structs::Key, :string, :uint, :uint], :uint
      attach_function :gpgme_op_keysign_start, [Structs::Context, Structs::Key, :string, :uint, :uint], :uint
      attach_function :gpgme_op_revsig, [Structs::Context, Structs::Key, Structs::Key, :string, :uint], :uint
      attach_function :gpgme_op_receive_keys, [Structs::Context, :pointer], :gpgme_error_t
      attach_function :gpgme_op_receive_keys_start, [Structs::Context, :pointer], :gpgme_error_t
      attach_function :gpgme_op_revsig_start, [Structs::Context, Structs::Key, Structs::Key, :string, :uint], :uint
      attach_function :gpgme_op_revuid, [Structs::Context, Structs::Key, :string, :uint], :uint
      attach_function :gpgme_op_revuid_start, [Structs::Context, Structs::Key, :string, :uint], :uint
      attach_function :gpgme_op_set_uid_flag, [Structs::Context, Structs::Key, :string, :string, :string], :uint
      attach_function :gpgme_op_set_uid_flag_start, [Structs::Context, Structs::Key, :string, :string, :string], :uint
      attach_function :gpgme_op_sign, [Structs::Context, :pointer, :pointer, :uint], :uint
      attach_function :gpgme_op_sign_result, [Structs::Context], :uint
      attach_function :gpgme_op_sign_start, [Structs::Context, :pointer, :pointer, :uint], :uint
      attach_function :gpgme_op_tofu_policy, [Structs::Context, Structs::Key, :uint], :uint
      attach_function :gpgme_op_tofu_policy_start, [Structs::Context, Structs::Key, :uint], :uint
      attach_function :gpgme_pubkey_algo_name, [:uint], :string
      attach_function :gpgme_pubkey_algo_string, [:pointer], :string
      attach_function :gpgme_release, [Structs::Context], :void
      attach_function :gpgme_result_ref, [:pointer], :void
      attach_function :gpgme_result_unref, [:pointer], :void
      attach_function :gpgme_set_armor, [Structs::Context, :bool], :void
      attach_function :gpgme_set_ctx_flag, [Structs::Context, :string, :string], :uint
      attach_function :gpgme_set_engine_info, [:uint, :string, :string], :int
      attach_function :gpgme_set_global_flag, [:string, :string], :int
      attach_function :gpgme_set_include_certs, [Structs::Context, :int], :void
      attach_function :gpgme_set_keylist_mode, [Structs::Context, :int], :uint
      attach_function :gpgme_set_locale, [Structs::Context, :int, :string], :uint
      attach_function :gpgme_set_offline, [Structs::Context, :bool], :void
      attach_function :gpgme_set_pinentry_mode, [Structs::Context, :uint], :uint
      attach_function :gpgme_set_protocol, [Structs::Context, :uint], :uint
      attach_function :gpgme_set_sender, [Structs::Context, :uint], :uint
      attach_function :gpgme_set_textmode, [Structs::Context, :bool], :void
      attach_function :gpgme_strerror, [:uint], :string
      attach_function :gpgme_strerror_r, [:uint, :buffer_in, :size_t], :uint
      attach_function :gpgme_strsource, [:uint], :string
      attach_function :gpgme_wait, [Structs::Context, :pointer, :int], Structs::Context
    end
  end
end
