require 'ffi'
require_relative 'constants'

module Crypt
  class GPGME
    module Structs
      extend FFI::Library
      include Crypt::GPGME::Constants

      enum :gpgme_protocol_t, [
        GPGME_PROTOCOL_OpenPGP,
        GPGME_PROTOCOL_CMS,
        GPGME_PROTOCOL_GPGCONF,
        GPGME_PROTOCOL_ASSUAN,
        GPGME_PROTOCOL_G13,
        GPGME_PROTOCOL_UISERVER,
        GPGME_PROTOCOL_SPAWN,
        GPGME_PROTOCOL_DEFAULT, 254,
        GPGME_PROTOCOL_UNKNOWN
      ]

      class EngineInfo < FFI::Struct
        layout(
          :next, :pointer,
          :protocol, :gpgme_protocol_t,
          :file_name, :string,
          :version, :string,
          :req_version, :string,
          :home_dir, :string
        )
      end
    end
  end
end
