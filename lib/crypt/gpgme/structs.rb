require 'ffi'
require_relative 'constants'

module Crypt
  class GPGME
    module Structs
      extend FFI::Library
      include Crypt::GPGME::Constants

      class FFI::Struct
        def to_hash
          hash = {}

          members.each do |member|
            next if member.to_s.start_with?('_')
            hash[member] = self[member]
          end

          hash
        end
      end

      # This is an opaque data structure, so I'm really just
      # reserving a blob of memory here.
      class Context < FFI::Struct
        layout(:context, :pointer)

        def pointer
          self[:context]
        end
      end

      # gpgme_revocation_key_t
      class RevocationKey < FFI::Struct
        layout(
          :next, :pointer,
          :pubkey_algo, :int,
          :fpr, :string,
          :key_class, :uint,
          :sensitive, :uint
        )
      end

      class SigNotation < FFI::Struct
        layout(
          :next, :pointer,
          :name, :string,
          :value, :string,
          :name_len, :int,
          :value_len, :int,
          :flags, :uint,
          :human_readable, :bool, 33,
          :critical, :bool, 34,
          :_unused, :int
        )
      end

      # gpgme_key_sig_t
      class KeySig < FFI::Struct
        layout(
          :next, :pointer,
          :revoked, :bool, 9,
          :expired, :bool, 10,
          :invalid, :bool, 11,
          :exportable, :bool, 12,
          :_unused, :uint, 13,
          :trust_depth, :uint, 14,
          :trust_value, :uint, 15,
          :pubkey_algo, :uint, 16,
          :keyid, :string,
          :_keyid, [:char, 17],
          :timestamp, :long,
          :expires, :long,
          :status, :uint,
          :_obsolete_class, :uint,
          :uid, :string,
          :name, :string,
          :email, :string,
          :comment, :string,
          :sig_class, :uint,
          :notation, :uint,
          :_last_notation, :pointer,
          :trust_scope, :string
        )
      end

      # gpgme_engine_info_t
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

      # gpgme_subkey_t
      class Subkey < FFI::Struct
        layout(
          :next, :pointer,
          :revoked, :bool, 9,
          :expired, :bool, 9,
          :disabled, :bool, 9,
          :invalid, :bool, 9,
          :can_encrypt, :bool, 9,
          :can_sign, :bool, 9,
          :can_certify, :bool, 9,
          :secret, :bool, 9,
          :can_authenticate, :bool, 10,
          :is_qualified, :bool, 10,
          :is_cardkey, :bool, 10,
          :is_de_vs, :bool, 10,
          :can_renc, :bool, 10,
          :can_timestamp, :bool, 10,
          :is_group_owned, :bool, 10,
          :beta_compliance, :bool, 10,
          :unused, :uint, 11,
          :pubkey_algo, :uint, 12,
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

      # gpgme_user_id_t
      class UserId < FFI::Struct
        layout(
          :next, :pointer,
          :revoked, :bool,
          :invalid, :bool,
          :_unused, :uint,
          :origin, :uint,
          :validity, :uint,
          :uid, :string,
          :name, :string,
          :email, :string,
          :comment, :string,
          :signatures, :pointer,
          :_last_keysig, :pointer,
          :tofu, :uint,
          :last_update, :ulong,
          :uidhash, :string
        )
      end

      # gpgme_key_t
      class Key < FFI::Struct
        layout(
          :_refs, :uint,
          :revoked, :bool, 4,
          :expired, :bool, 4,
          :disabled, :bool, 4,
          :invalid, :bool, 4,
          :can_encrypt, :bool, 5,
          :can_sign, :bool, 5,
          :can_certify, :bool, 5,
          :secret, :bool, 5,
          :can_authenticate, :bool, 6,
          :is_qualified, :bool, 6,
          :has_encrypt, :bool, 6,
          :has_sign, :bool, 6,
          :has_certify, :bool, 7,
          :has_authenticate, :bool, 7,
          :_unused, :uint, 7,
          :origin, :int, 7,
          :protocol, :uint, 8,
          :issuer_serial, :string,
          :issuer_name, :string,
          :chain_id, :string,
          :owner_trust, :uint,
          :subkeys, :pointer,
          :uids, :pointer,
          :_last_subkey, :pointer,
          :_last_uid, :pointer,
          :keylist_mode, :uint,
          :fpr, :string,
          :last_update, :ulong,
          :revocation_keys, :pointer,
          :_last_revkey, :pointer
        )
      end

      # gpgme_tofu_info_t
      class TofuInfo < FFI::Struct
        layout(
          :next, :pointer,
          :validity, :uint, 9,
          :policy, :uint, 10,
          :_rfu, :uint, 11,
          :signcount, :ushort, 12,
          :encrcount, :ushort, 14,
          :signfirst, :ulong, 16,
          :signlast, :ulong, 24,
          :encrfirst, :ulong, 32,
          :encrlast, :ulong, 40,
          :description, :string, 48
        )
      end
    end
  end
end
