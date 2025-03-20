require 'ffi'

module Crypt
  class GPGME
    module Typedefs
      extend FFI::Library

      typedef :uint, :gpgme_error_t
      typedef :uint, :gpg_err_source_t
      typedef :uint, :gpgme_protocol_t
      typedef :uint, :gpgme_conf_level_t
      typedef :uint, :gpgme_pubkey_algo_t
      typedef :uint, :gpgme_hash_algo_t
      typedef :uint, :gpgme_pinentry_mode_t
      typedef :uint, :gpgme_keylist_mode_t
      typedef :uint, :gpgme_validity_t
      typedef :uint, :gpgme_tofu_policy_t
      typedef :uint, :gpgme_keyorg_t
      typedef :uint, :gpgme_sigsum_t
    end
  end
end
