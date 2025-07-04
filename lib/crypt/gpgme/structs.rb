require 'ffi'
require 'ffi/bit_struct'
require_relative 'constants'

module Crypt
  class GPGME
    module Structs
      extend FFI::Library

      class FFI::Struct
        def to_hash
          hash = {}
          bitfields = respond_to?(:bit_field_members) ? bit_field_members : {}

          members.flat_map { |m| bitfields[m] || m }.each do |member|
            next if member.to_s.start_with?('_') # Skip unused members
            next if member.to_s == 'next'        # Skip linked list pointers

            if self[member].is_a?(FFI::Pointer) and self[member].null?
              hash[member] = nil
            else
              hash[member] = self[member]
            end
          end

          hash
        end
      end

      class Data < FFI::Struct
        layout(:dh, :pointer)

        def pointer
          self[:dh]
        end

        def dh
          self[:dh].read_pointer
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
        layout(:_properties, :uint)
        bit_fields(:_properties, :truncated, 1, :_unused, 31)
      end

      # gpgme_tofu_info_t
      class TofuInfo < FFI::BitStruct
        layout(
          :next, :pointer,
          :_properties, :uint, # bit fields
          :signcount, :ushort,
          :encrcount, :ushort,
          :signfirst, :ulong,
          :signlast, :ulong,
          :encrfirst, :ulong,
          :encrlast, :ulong,
          :description, :string,
        )

        bit_fields(:_properties,
          :validity, 3,
          :policy, 4,
          :_rfu, 25
        )
      end

      # gpgme_revocation_key_t
      class RevocationKey < FFI::BitStruct
        layout(
          :next, :pointer,
          :pubkey_algo, :int,
          :fpr, :string,
          :key_class, :uint,
          :_properties, :uint # bit fields
        )

        bit_fields(:_properties, :sensitive, 1)
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
          :_properties, :uint # bit fields
        )

        bit_fields(:_properties,
          :human_readable, 1,
          :critical, 1,
          :_unused, 30
        )
      end

      # gpgme_key_sig_t
      class KeySig < FFI::BitStruct
        layout(
          :next, :pointer,
          :_properties, :uint, # bit fields
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
          :notations, :pointer,
          :_last_notation, :pointer,
          :trust_scope, :string
        )

        bit_fields(:_properties,
          :revoked, 1,
          :expired, 1,
          :invalid, 1,
          :exportable, 1,
          :_unused, 12,
          :trust_depth, 8,
          :trust_value, 8
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
          :_properties, :uint, # bit fields
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

        bit_fields(:_properties,
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
          :_properties, :uint, # bit fields
          :validity, :uint,
          :uid, :string,
          :name, :string,
          :email, :string,
          :comment, :string,
          :signatures, KeySig.by_ref,
          :_last_keysig, :pointer,
          :address, :string,
          :tofu, TofuInfo.by_ref,
          :last_update, :ulong,
          :uidhash, :string
        )

        bit_fields(:_properties,
          :revoked, 1,
          :invalid, 1,
          :_unused, 25,
          :origin, 5
        )

        def to_hash
          hash = super
          hash[:tofu] = nil if self[:tofu].null?

          if self[:signatures].null?
            hash[:signatures] = nil
          else
            sig_array = []
            sig = self[:signatures]
            sig_array << sig

            loop do
              sig = Crypt::GPGME::Structs::KeySig.new(sig[:next])
              break if sig.null?
              sig_array << sig
            end

            hash[:signatures] = sig_array.map(&:to_hash)
          end

          hash
        end
      end

      # gpgme_key_t
      class Key < FFI::BitStruct
        include Crypt::GPGME::Constants

        layout(
          :_refs, :uint,
          :_properties, :uint, # bit fields
          :protocol, :uint,
          :issuer_serial, :string,
          :issuer_name, :string,
          :chain_id, :string,
          :owner_trust, :uint,
          :subkeys, Subkey.by_ref,
          :uids, UserId.by_ref,
          :_last_subkey, :pointer,
          :_last_uid, :pointer,
          :keylist_mode, :uint,
          :fpr, :string,
          :last_update, :ulong,
          :revocation_keys, :pointer,
          :_last_revkey, :pointer
        )

        bit_fields(:_properties,
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

        bit_field_members.values.last.each do |member|
          unless member.to_s.start_with?('_')
            define_method "#{member}?" do
              self[member] == 1 ? true : false
            end
          end
        end

        def to_hash
          hash = super
          uid_array = []
          subkey_array = []

          uid = self[:uids]
          subkey = self[:subkeys]

          uid_array << uid
          subkey_array << subkey

          loop do
            uid = Crypt::GPGME::Structs::UserId.new(uid[:next])
            break if uid.null?
            uid_array << uid
          end

          loop do
            subkey = Crypt::GPGME::Structs::Subkey.new(subkey[:next])
            break if subkey.null?
            subkey_array << subkey
          end

          hash[:uids] = uid_array.map(&:to_hash)
          hash[:subkeys] = subkey_array.map(&:to_hash)

          hash
        end

        def fingerprint
          self[:fpr]
        end

        def last_update
          self[:last_update] == 0 ? 'unknown' : Time.at(self[:last_update])
        end

        def chain_id
          self[:chain_id]
        end

        def issuer_name
          self[:issuer_name]
        end

        def issuer_serial
          self[:issuer_serial]
        end

        def protocol(numeric = false)
          if numeric
            self[:protocol]
          else
            case self[:protocol]
              when GPGME_PROTOCOL_OpenPGP
                'openpgp'
              when GPGME_PROTOCOL_CMS
                'cms'
              when GPGME_PROTOCOL_GPGCONF
                'gpgconf'
              when GPGME_PROTOCOL_ASSUAN
                'assuan'
              when GPGME_PROTOCOL_G13
                'g13'
              when GPGME_PROTOCOL_UISERVER
                'uiserver'
              when GPGME_PROTOCOL_SPAWN
                'spawn'
              when GPGME_PROTOCOL_DEFAULT
                'default'
              when GPGME_PROTOCOL_UNKNOWN
                'unknown'
              else
                'unknown'
            end
          end
        end

        def owner_trust(numeric = false)
          if numeric
            self[:owner_trust]
          else
            case self[:owner_trust]
              when GPGME_VALIDITY_UNKNOWN
                'unknown'
              when GPGME_VALIDITY_UNDEFINED
                'undefined'
              when GPGME_VALIDITY_NEVER
                'never'
              when GPGME_VALIDITY_MARGINAL
                'marginal'
              when GPGME_VALIDITY_FULL
                'full'
              when GPGME_VALIDITY_ULTIMATE
                'ultimate'
              else
                'unknown'
            end
          end
        end

        def keylist_mode(numeric = false)
          if numeric
            self[:keylist_mode]
          else
            case self[:keylist_mode]
              when GPGME_KEYLIST_MODE_LOCAL
                'local'
              when GPGME_KEYLIST_MODE_EXTERN
                'extern'
              when GPGME_KEYLIST_MODE_SIGS
                'sigs'
              when GPGME_KEYLIST_MODE_SIG_NOTATIONS
                'signature notations'
              when GPGME_KEYLIST_MODE_WITH_SECRET
                'with secret'
              when GPGME_KEYLIST_MODE_WITH_TOFU
                'with tofu'
              when GPGME_KEYLIST_MODE_WITH_KEYGRIP
                'with keygrip'
              when GPGME_KEYLIST_MODE_EPHEMERAL
                'ephemeral'
              when GPGME_KEYLIST_MODE_VALIDATE
                'validate'
              when GPGME_KEYLIST_MODE_FORCE_EXTERN
                'extern'
              when GPGME_KEYLIST_MODE_WITH_V5FPR
                'with v5fpr'
              when GPGME_KEYLIST_MODE_LOCATE
                'locate'
              when GPGME_KEYLIST_MODE_LOCATE_EXTERNAL
                'locate external'
              else
                'unknown'
            end
          end
        end
      end
    end
  end
end
