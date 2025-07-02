require_relative 'gpgme/constants'
require_relative 'gpgme/functions'
require_relative 'gpgme/context'
require_relative 'gpgme/engine'
require_relative 'gpgme/algorithm'
require_relative 'gpgme/data'

module Crypt
  class GPGME
    include Crypt::GPGME::Constants
    include Crypt::GPGME::Functions
    extend Crypt::GPGME::Functions
    extend Crypt::GPGME::Constants

    class Error < StandardError; end

    VERSION = '0.1.0'

    def initialize
      gpgme_check_version(nil) # Initialize subsystems
    end

    class << self
      # Return the version number for the gpgme library.
      #
      # If the +required+ parameter is not nil, the method checks that the
      # version of the gpgme library is at least as high as the version number
      # provided. If it is not, then nil is returned instead.
      #
      # Note that this method also invokes some subsystems, and should be
      # invoked first before using other gpgme methods.
      #
      def check_version(required = nil)
        gpgme_check_version(required)
      end

      # Set a global flag. The possible flags are:
      #
      # * debug
      # * disable-gpgconf
      # * gpg-name (or gpgconf-name)
      # * require-gnupg
      # * inst-type
      # * w32-inst-dir
      #
      # Example:
      #
      #   Crypt::GPGME.set_global_flag("debug", "9:/Users/your_userid/mygpgme.log")
      #
      def set_global_flag(key, value)
        if gpgme_set_global_flag(key, value) != 0
          raise Error, "gpgme_set_global_flag failed"
        end
      end
    end
  end
end

if $0 == __FILE__

=begin
#p Crypt::GPGME.set_global_flag("debug", "9:/Users/daniel.berger/mygpgme.log")
require 'pp'
p Crypt::GPGME.check_version
p Crypt::GPGME::Engine.check_version
#p Crypt::GPGME::Structs::EngineInfo.size
pp Crypt::GPGME::Engine.get_info
=end
#=begin
#p Crypt::GPGME.check_version
ctx = Crypt::GPGME::Context.new
fpr = "C9D8 3C01 0035 9499 0E2F  E6C6 3D41 5506 6C03 D7EB"
ctx.keylist_mode = Crypt::GPGME::GPGME_KEYLIST_MODE_LOCAL | Crypt::GPGME::GPGME_KEYLIST_MODE_SIGS

#sig = ctx.sign("hello world")
#pp sig.to_hash

#key = ctx.get_key(fpr)
#pp key.to_hash
#hash = key.to_hash
#uid = hash[:uids].first

data = Crypt::GPGME::Data.new("hello world")
#pp data
p data.to_s

#pp uid[:signatures].map{ |h| h[:keyid] }
#p ctx.protocol
#ctx.protocol = Crypt::GPGME::GPGME_PROTOCOL_ASSUAN
#p ctx.protocol
#p ctx.get_engine_info
#p ctx.armor?
#ctx.armor = true
#p ctx.armor?
#p ctx.text_mode?
#p ctx.pinentry_mode
#p ctx.include_certs
#p ctx.keylist_mode
#p ctx.get_flag("redraw")
#p ctx.get_flag("known-notations")
#p ctx.get_flag("bogus")
#p ctx.list_keys
#=end

end
