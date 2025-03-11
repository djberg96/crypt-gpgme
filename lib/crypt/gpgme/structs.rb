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
    end
  end
end
