require 'ffi'
require 'ffi/bit_struct'
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

      # gpgme_op_keylist_result_t
      class KeylistResult < FFI::BitStruct
        layout(:properties, :uint)
        bit_fields(:properties, :truncated, 1, :_unused, 31)
      end

      # gpgme_revocation_key_t
      class RevocationKey < FFI::BitStruct
        layout(
          :next, :pointer,
          :pubkey_algo, :int,
          :fpr, :string,
          :key_class, :uint,
          :properties, :uint # bit fields
        )

        bit_fields(:properties, :sensitive, 1)
      end

      # struct _gpgme_sig_notation
      class SigNotation < FFI::BitStruct
        layout(
          :next, :pointer,
          :name, :string,
          :value, :string,
          :name_len, :int,
          :value_len, :int,
          :flags, :uint,
          :properties, :uint # bit fields
        )

        bit_fields(:properties,
          :human_readable, 1,
          :critical, 1,
          :_unused, 30
        )
      end

      # gpgme_key_sig_t
      class KeySig < FFI::BitStruct
        layout(
          :next, :pointer,
          :properties, :uint,
          :trust_depth, :uint,
          :trust_value, :uint,
          :pubkey_algo, :uint,
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

        bit_fields(:properties,
          :revoked, 1,
          :expired, 1,
          :invalid, 1,
          :exportable, 1,
          :_unused, 12
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
      class Subkey < FFI::BitStruct
        layout(
          :next, :pointer,
          :properties, :uint, # bit fields
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

        bit_fields(:properties,
          :revoked, 1,
          :expired, 1,
          :disabled, 1,
          :invalid, 1,
          :can_encrypt, 1,
          :can_sign, 1,
          :can_certify, 1,
          :secret, 1,
          :can_authenticate, 1,
          :is_qualified, 1,
          :is_cardkey, 1,
          :is_de_vs, 1,
          :can_renc, 1,
          :can_timestamp, 1,
          :is_group_owned, 1,
          :beta_compliance, 1,
          :unused, 16
        )
      end

      # gpgme_user_id_t
      class UserId < FFI::BitStruct
        layout(
          :next, :pointer,
          :properties, :uint, # bit fields
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

        bit_fields(:properties,
          :revoked, 1,
          :invalid, 1,
          :_unused, 25,
          :origin, 5
        )
      end

      # gpgme_key_t
      class Key < FFI::BitStruct
        layout(
          :_refs, :uint,
          :properties, :uint, # bit fields
          :protocol, :uint,
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

        bit_fields(:properties,
          :revoked, 1,
          :expired, 1,
          :disabled, 1,
          :invalid, 1,
          :can_encrypt, 1,
          :can_sign, 1,
          :can_certify, 1,
          :secret, 1,
          :can_authenticate, 1,
          :is_qualified, 1,
          :has_encrypt, 1,
          :has_sign, 1,
          :has_certify, 1,
          :has_authenticate, 1,
          :_unused, 13,
          :origin, 5
        )
      end

      # gpgme_tofu_info_t
      class TofuInfo < FFI::BitStruct
        layout(
          :next, :pointer,
          :properties, :uint, # bit fields
          :signcount, :ushort,
          :encrcount, :ushort,
          :signfirst, :ulong,
          :signlast, :ulong,
          :encrfirst, :ulong,
          :encrlast, :ulong,
          :description, :string,
        )

        bit_fields(:properties,
          :validity, 3,
          :policy, 4,
          :_rfu, 25
        )
      end
    end
  end
end
