#!/usr/bin/env ruby
#######################################################################
# set_expire_example.rb
#
# Example demonstrating how to set key expiration times.
#
# NOTE: This example requires:
# - A valid key in your keyring
# - The key's passphrase (you'll be prompted via pinentry)
# - Permission to modify the key
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
  puts "Usage: ruby set_expire_example.rb <key_id>"
  exit 1
end

key = keys.first
puts "Found key: #{key.uids.first.uid}"

# Calculate expiration times
one_year = 365 * 24 * 60 * 60
six_months = 180 * 24 * 60 * 60
never_expire = 0

puts "\nExpiration examples:"
puts "===================="
puts "To set primary key to expire in 1 year:"
puts "  ctx.set_expire(key, #{one_year})"
puts ""
puts "To set primary key to never expire:"
puts "  ctx.set_expire(key, #{never_expire})"
puts ""
puts "To set specific subkeys to expire in 6 months:"
puts "  ctx.set_expire(key, #{six_months}, \"FPR1\\nFPR2\")"
puts ""

# Show current expiration
puts "Current key information:"
puts "  Expires: #{key.expires > 0 ? Time.at(key.expires) : 'Never'}"

if key.subkeys.length > 1
  puts "\n  Subkeys:"
  key.subkeys[1..-1].each do |subkey|
    puts "    #{subkey.keyid}: #{subkey.expires > 0 ? Time.at(subkey.expires) : 'Never'}"
  end
end

puts "\nNOTE: Actually modifying the key requires passphrase authentication."
puts "Uncomment the following line to test (requires valid passphrase):"
puts ""
puts "# Set primary key to expire in 1 year"
puts "# ctx.set_expire(key, #{one_year})"

# Uncomment to actually perform the operation:
# ctx.set_expire(key, one_year)

ctx.release
puts "\nDone!"
