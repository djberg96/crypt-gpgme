require 'ffi'
require_relative 'constants'

module Crypt
  class GPGME
    module Structs
      extend FFI::Library
      include Crypt::GPGME::Constants

      # This is an opaque data structure, so I'm really just
      # reserving a blob of memory here.
      class Context < FFI::Struct
        layout(:_unused, [:void, 1024])
      end

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

      # gpgme_key_t
      class Key < FFI::Struct
        layout(
          :_refs, :uint,
          :revoked, :bool,
          :expired, :bool,
          :disabled, :bool,
          :invalid, :bool,
          :can_encrypt, :bool,
          :can_sign, :bool,
          :can_certify, :bool,
          :secret, :bool,
          :can_authenticate, :bool,
          :is_qualified, :bool,
          :has_encrypt, :bool,
          :has_sign, :bool,
          :has_certify, :bool,
          :has_authenticate, :bool,
          :_unused, :uint,
          :origin, :int,
          :protocol, :uint,
          :issuer_serial, :string,
          :issuer_name, :string,
          :chain_id, :string,
          :owner_trust, :pointer,
          :subkeys, :pointer,
          :uids, :pointer,
          :_last_subkey, :pointer,
          :_last_uid, :pointer,
          :keylist_mode, :pointer,
          :fpr, :string,
          :last_update, :ulong,
          :revocation_keys, :pointer,
          :_last_revkey, :pointer
        )
      end

      # gpgme_subkey_t
      class Subkey < FFI::Struct
        layout(
          :next, :pointer,
          :revoked, :bool,
          :expired, :bool,
          :disabled, :bool,
          :invalid, :bool,
          :can_encrypt, :bool,
          :can_sign, :bool,
          :can_certify, :bool,
          :secret, :bool,
          :can_authenticate, :bool,
          :is_qualified, :bool,
          :is_cardkey, :bool,
          :is_de_vs, :bool,
          :can_renc, :bool,
          :can_timestamp, :bool,
          :is_group_owned, :bool,
          :beta_compliance, :bool,
          :unused, :uint,
          :pubkey_algo, :uint,
          :length, :int,
          :keyid, :string,
          :_keyid, [:char, 17],
          :fpr, :string,
          :timestamp, :long,
          :expires, :long,
          :card_number, :string,
          :curve, :string,
          :keygrip, :string,
          :v5fpr, :string
        )
      end

=begin
      class UserId < FFI::Struct
        layout(
        )
      end

      class TofuInfo < FFI::Struct
        layout(
        )
      end

      class KeySig < FFI::Struct
        layout(
        )
      end
=end

      class RevocationKey < FFI::Struct
        layout(
          :next, :pointer,
          :pubkey_algo, :int,
          :fpr, :string,
          :key_class, :uint,
          :sensitive, :uint
        )
      end
    end
  end
end
