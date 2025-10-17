#!/usr/bin/env ruby
#######################################################################
# set_owner_trust_example.rb
#
# Example demonstrating how to set owner trust levels on keys.
#
# NOTE: This example requires:
# - A valid OpenPGP key in your keyring
# - Appropriate permissions to modify trust settings
# - Understanding of the Web of Trust model
#######################################################################
require 'crypt/gpgme'

# Create a new context
ctx = Crypt::GPGME::Context.new

# Find a key to modify (replace with your own key identifier)
key_id = ARGV[0] || "your.email@example.com"

puts "Looking for key: #{key_id}"
keys = ctx.list_keys(key_id)

if keys.empty?
  puts "No key found for: #{key_id}"
  puts "Usage: ruby set_owner_trust_example.rb <key_id>"
  exit 1
end

key = keys.first
puts "Found key: #{key.uids.first.uid}"

# Display trust level names and their meanings
puts "\nOwner Trust Levels:"
puts "===================="
puts "unknown    (0): Unknown trust level"
puts "undefined  (1): Trust level has not been defined"
puts "never      (2): Never trust this key owner to certify other keys"
puts "marginal   (3): Marginally trust this key owner to certify keys"
puts "full       (4): Fully trust this key owner to certify other keys"
puts "ultimate   (5): Ultimate trust (typically for your own keys)"
puts ""

# Show current owner trust
trust_names = {
  0 => "unknown",
  1 => "undefined",
  2 => "never",
  3 => "marginal",
  4 => "full",
  5 => "ultimate"
}

current_trust = key.owner_trust
puts "Current owner trust: #{trust_names[current_trust]} (#{current_trust})"
puts ""

# Show usage examples
puts "Usage Examples:"
puts "==============="
puts ""
puts "Set owner trust using string values:"
puts "  ctx.set_owner_trust(key, \"full\")"
puts "  ctx.set_owner_trust(key, \"ultimate\")"
puts "  ctx.set_owner_trust(key, \"marginal\")"
puts ""
puts "Set owner trust using integer constants:"
puts "  ctx.set_owner_trust(key, 4)  # Full trust"
puts "  ctx.set_owner_trust(key, 5)  # Ultimate trust"
puts "  ctx.set_owner_trust(key, Crypt::GPGME::GPGME_VALIDITY_FULL)"
puts ""
puts "Asynchronous version:"
puts "  ctx.set_owner_trust_start(key, \"full\")"
puts "  ctx.wait"
puts ""

# Important notes
puts "IMPORTANT NOTES:"
puts "================"
puts "• Owner trust is YOUR assessment of how much you trust this key owner"
puts "  to properly verify and certify other people's keys."
puts "• This is different from key validity, which is calculated automatically"
puts "  based on signatures and trust paths."
puts "• Setting owner trust affects the Web of Trust calculations for all keys"
puts "  signed by this key owner."
puts "• Only set 'ultimate' trust for keys you personally control."
puts "• 'full' trust means you trust this person's key certification judgement"
puts "  as much as your own."
puts ""

puts "To actually modify the trust level, uncomment one of these lines:"
puts ""
puts "# Set to full trust:"
puts "# ctx.set_owner_trust(key, \"full\")"
puts ""
puts "# Set to marginal trust:"
puts "# ctx.set_owner_trust(key, \"marginal\")"

# Uncomment to actually perform the operation:
# ctx.set_owner_trust(key, "full")
# puts "Owner trust updated to 'full'"

ctx.release
puts "\nDone!"
