#!/usr/bin/env ruby
#######################################################################
# create_key_example.rb
#
# Example demonstrating how to create keys and subkeys.
#
# NOTE: This example requires:
# - Passphrase entry via pinentry or passphrase callback
# - Appropriate system permissions
# - Time for key generation (RSA keys can be slow)
#######################################################################
require 'crypt/gpgme'

# Create a new context
ctx = Crypt::GPGME::Context.new

puts "Key Creation Examples"
puts "=" * 80
puts ""

# Display available algorithms
puts "Common Key Algorithms:"
puts "  rsa2048      - RSA 2048-bit (standard, widely compatible)"
puts "  rsa3072      - RSA 3072-bit (stronger)"
puts "  rsa4096      - RSA 4096-bit (strongest RSA, slowest)"
puts "  ed25519      - EdDSA 25519 (fast, modern, signing only)"
puts "  cv25519      - ECDH Curve25519 (encryption)"
puts "  future-default - Let GPGME choose best current algorithm"
puts ""

# Display creation flags
puts "Creation Flags (can be combined with bitwise OR):"
puts "  GPGME_CREATE_SIGN       - Allow signing capability"
puts "  GPGME_CREATE_ENCR       - Allow encryption capability"
puts "  GPGME_CREATE_CERT       - Allow certification capability"
puts "  GPGME_CREATE_AUTH       - Allow authentication capability"
puts "  GPGME_CREATE_NOPASSWD   - Create without passphrase"
puts "  GPGME_CREATE_NOEXPIRE   - Create without expiration"
puts "  GPGME_CREATE_SELFSIGNED - Create self-signed certificate"
puts ""

# Usage examples
puts "Usage Examples:"
puts "=" * 80
puts ""

puts "1. Create a basic RSA key:"
puts "   result = ctx.create_key(\"Alice <alice@example.com>\", \"rsa2048\")"
puts "   puts \"Created key: \#{result[:fpr]}\""
puts ""

puts "2. Create an Ed25519 key (modern, fast):"
puts "   result = ctx.create_key(\"Bob <bob@example.com>\", \"ed25519\")"
puts ""

puts "3. Create key with specific capabilities:"
puts "   flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_ENCR"
puts "   result = ctx.create_key(\"Carol <carol@example.com>\", \"rsa2048\", 0, 0, nil, flags)"
puts ""

puts "4. Create key that expires in 1 year:"
puts "   one_year = 365 * 24 * 60 * 60"
puts "   result = ctx.create_key(\"Dave <dave@example.com>\", \"rsa2048\", 0, one_year)"
puts ""

puts "5. Create key that never expires:"
puts "   flags = Crypt::GPGME::GPGME_CREATE_NOEXPIRE"
puts "   result = ctx.create_key(\"Eve <eve@example.com>\", \"rsa2048\", 0, 0, nil, flags)"
puts ""

puts "6. Create signing key and add encryption subkey:"
puts "   # Create primary key for signing/certification"
puts "   flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT"
puts "   result = ctx.create_key(\"Frank <frank@example.com>\", \"ed25519\", 0, 0, nil, flags)"
puts "   "
puts "   # Retrieve the key"
puts "   key = ctx.list_keys(\"frank@example.com\").first"
puts "   "
puts "   # Add encryption subkey"
puts "   flags = Crypt::GPGME::GPGME_CREATE_ENCR"
puts "   result = ctx.create_subkey(key, \"cv25519\", 0, 0, flags)"
puts ""

puts "7. Asynchronous key creation:"
puts "   ctx.create_key_start(\"Grace <grace@example.com>\", \"rsa2048\")"
puts "   ctx.wait"
puts "   result = ctx.get_genkey_result"
puts ""

puts "=" * 80
puts ""

# Important notes
puts "IMPORTANT NOTES:"
puts "=" * 80
puts "• Key generation requires passphrase entry via pinentry"
puts "  (unless GPGME_CREATE_NOPASSWD flag is used)"
puts "• RSA key generation can be slow, especially for larger keys"
puts "• Modern algorithms (ed25519, cv25519) are much faster"
puts "• Ed25519 is for signing, Cv25519 is for encryption"
puts "• Primary keys typically have signing and certification capabilities"
puts "• Subkeys are used for encryption or additional signing keys"
puts "• You can create multiple subkeys with different purposes/expirations"
puts ""

puts "Best Practices:"
puts "• Use ed25519 for signing (fast, secure, widely supported)"
puts "• Use cv25519 for encryption"
puts "• Keep primary key offline, use subkeys for daily operations"
puts "• Set expiration dates for subkeys (easier to rotate)"
puts "• Use strong passphrases"
puts "• Back up your keys securely"
puts ""

# Example with actual key creation (commented out for safety)
puts "To actually create a key, uncomment and run:"
puts ""
puts "# Create a test key"
puts "# result = ctx.create_key(\"Test User <test@example.com>\", \"ed25519\")"
puts "# puts \"Created key with fingerprint: \#{result[:fpr]}\""
puts "#"
puts "# # Retrieve and display the key"
puts "# key = ctx.list_keys(\"test@example.com\").first"
puts "# puts \"User ID: \#{key.uids.first.uid}\""
puts "# puts \"Algorithm: \#{key.subkeys.first.pubkey_algo_name}\""
puts "#"
puts "# # Add an encryption subkey"
puts "# flags = Crypt::GPGME::GPGME_CREATE_ENCR"
puts "# result = ctx.create_subkey(key, \"cv25519\", 0, 0, flags)"
puts "# puts \"Added subkey with fingerprint: \#{result[:fpr]}\""

# Uncomment to actually create a test key:
# result = ctx.create_key("Test User <test@example.com>", "ed25519")
# puts "Created key with fingerprint: #{result[:fpr]}"

ctx.release
puts "\nDone!"
