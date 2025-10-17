#!/usr/bin/env ruby
# frozen_string_literal: true

# User ID Flag Management Example
#
# This script demonstrates how to set and manage flags on user IDs
# using the crypt-gpgme library. The primary use case is setting
# the "primary" flag to designate which UID is the main identity.
#
# WARNING: This script contains examples that will modify keys in your keyring.
# The actual modification calls are commented out by default.

require 'crypt/gpgme'

def separator
  puts "\n" + "=" * 70 + "\n\n"
end

puts "User ID Flag Management Examples"
puts "=" * 70

# Initialize context
ctx = Crypt::GPGME::Context.new
ctx.armor = true

# Example 1: Understanding the Primary Flag
separator
puts "Example 1: Understanding the Primary Flag"
puts "-" * 70

puts "The 'primary' flag marks which user ID is the main identity on a key."
puts ""
puts "Benefits of setting a primary UID:"
puts "  • Appears first in key listings"
puts "  • Used by default in email clients"
puts "  • Indicates your preferred contact email"
puts "  • Helps others know which identity to use"
puts ""
puts "Note: Only one UID can be primary at a time."
puts "      Setting a new primary automatically clears the old one."

# Example 2: Setting a Primary UID
separator
puts "Example 2: Setting a Primary UID"
puts "-" * 70

test_email = "alice@example.com"

puts "Setting a user ID as primary:"
puts "  Key:    alice@example.com"
puts "  UID:    Alice Smith <alice@work.com>"
puts "  Flag:   primary"
puts "  Value:  1 (to set the flag)"
puts ""

# UNCOMMENT TO TEST:
# keys = ctx.list_keys(test_email, 1)
# if !keys.empty?
#   key = keys.first
#   begin
#     ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")
#     puts "✓ Successfully set primary flag"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# else
#   puts "No secret keys found for #{test_email}"
# end

puts "(Uncomment the code to test actual flag setting)"

# Example 3: Changing the Primary UID
separator
puts "Example 3: Changing the Primary UID"
puts "-" * 70

puts "When you set a new UID as primary, the old primary is automatically cleared."
puts ""
puts "Steps:"
puts "  1. Current primary: Alice Smith <alice@work.com>"
puts "  2. Set new primary:  Alice Smith <alice@personal.net>"
puts "  3. Result: Only personal.net is primary"
puts ""

# UNCOMMENT TO TEST:
# keys = ctx.list_keys(test_email, 1)
# if !keys.empty?
#   key = keys.first
#
#   begin
#     # Just set the new primary - old one is cleared automatically
#     ctx.set_uid_flag(key, "Alice Smith <alice@personal.net>", "primary", "1")
#     puts "✓ Changed primary UID to alice@personal.net"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# end

puts "(Uncomment the code to test)"

# Example 4: Clearing the Primary Flag
separator
puts "Example 4: Clearing the Primary Flag"
puts "-" * 70

puts "You can clear the primary flag using value '0' or nil:"
puts ""
puts "Method 1: Using '0'"
puts "  ctx.set_uid_flag(key, uid, 'primary', '0')"
puts ""
puts "Method 2: Using nil"
puts "  ctx.set_uid_flag(key, uid, 'primary', nil)"
puts ""
puts "Note: It's usually better to have one primary UID rather than none."

# UNCOMMENT TO TEST:
# keys = ctx.list_keys(test_email, 1)
# if !keys.empty?
#   key = keys.first
#
#   begin
#     # Clear using "0"
#     ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "0")
#     puts "✓ Cleared primary flag using '0'"
#
#     # Or clear using nil
#     # ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", nil)
#     # puts "✓ Cleared primary flag using nil"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# end

puts "(Uncomment the code to test)"

# Example 5: Asynchronous Flag Setting
separator
puts "Example 5: Asynchronous Flag Setting"
puts "-" * 70

puts "For non-blocking operations, use set_uid_flag_start:"

# UNCOMMENT TO TEST:
# keys = ctx.list_keys(test_email, 1)
# if !keys.empty?
#   key = keys.first
#
#   begin
#     ctx.set_uid_flag_start(key, "Alice Smith <alice@work.com>", "primary", "1")
#     puts "Started setting primary flag asynchronously..."
#
#     # Do other work here...
#     puts "Waiting for operation to complete..."
#     ctx.wait
#
#     puts "✓ Primary flag set"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# end

puts "(Uncomment the code to test)"

# Example 6: Complete UID Management Workflow
separator
puts "Example 6: Complete UID Management Workflow"
puts "-" * 70

puts "Managing multiple UIDs with primary flag:"
puts ""
puts "# 1. Get the key"
puts "keys = ctx.list_keys('alice@example.com', 1)"
puts "key = keys.first"
puts ""
puts "# 2. Add multiple UIDs"
puts "ctx.add_uid(key, 'Alice Smith (Work) <alice@work.com>')"
puts "ctx.add_uid(key, 'Alice Smith (Personal) <alice@personal.net>')"
puts "ctx.add_uid(key, 'Alice Smith (Projects) <alice@projects.org>')"
puts ""
puts "# 3. Set the work email as primary"
puts "ctx.set_uid_flag(key, 'Alice Smith (Work) <alice@work.com>', 'primary', '1')"
puts ""
puts "# 4. Later, change to personal as primary"
puts "ctx.set_uid_flag(key, 'Alice Smith (Personal) <alice@personal.net>', 'primary', '1')"
puts ""
puts "# 5. Revoke old work email (if needed)"
puts "ctx.revoke_uid(key, 'Alice Smith (Work) <alice@work.com>')"

# Example 7: Value Type Conversion
separator
puts "Example 7: Value Type Conversion"
puts "-" * 70

puts "The value parameter can be a string, integer, or nil:"
puts ""
puts "String value (recommended):"
puts "  ctx.set_uid_flag(key, uid, 'primary', '1')"
puts ""
puts "Integer value (automatically converted):"
puts "  ctx.set_uid_flag(key, uid, 'primary', 1)"
puts ""
puts "Nil value (clears the flag):"
puts "  ctx.set_uid_flag(key, uid, 'primary', nil)"

# Example 8: Error Handling
separator
puts "Example 8: Error Handling"
puts "-" * 70

puts "Handling common errors:"

# Error 1: Nil key
puts "\n1. Trying to set flag with nil key:"
begin
  ctx.set_uid_flag(nil, "Test <test@example.com>", "primary", "1")
rescue Crypt::GPGME::Error => e
  puts "   ✓ Caught error: #{e.message}"
end

# Error 2: Nil UID
puts "\n2. Trying to set flag with nil userid:"
keys = ctx.list_keys(nil, 1)
unless keys.empty?
  begin
    ctx.set_uid_flag(keys.first, nil, "primary", "1")
  rescue Crypt::GPGME::Error => e
    puts "   ✓ Caught error: #{e.message}"
  end
end

# Error 3: Nil flag
puts "\n3. Trying to set with nil flag:"
unless keys.empty?
  begin
    ctx.set_uid_flag(keys.first, "Test <test@example.com>", nil, "1")
  rescue Crypt::GPGME::Error => e
    puts "   ✓ Caught error: #{e.message}"
  end
end

# Error 4: Public key instead of secret key
puts "\n4. Trying to modify a public key:"
public_keys = ctx.list_keys("someone@example.com", 0)
unless public_keys.empty?
  begin
    ctx.set_uid_flag(public_keys.first, "Test <test@example.com>", "primary", "1")
  rescue Crypt::GPGME::Error => e
    puts "   ✓ Caught error: #{e.message}"
  end
else
  puts "   (No public keys to test with)"
end

# Example 9: Best Practices
separator
puts "Example 9: Best Practices"
puts "-" * 70

puts "Recommended patterns for UID flag management:"
puts ""

puts "1. Always maintain one primary UID:"
puts "   ✓ ctx.set_uid_flag(key, 'Alice <alice@main.com>', 'primary', '1')"
puts "   ✗ Having no primary can cause unpredictable behavior"
puts ""

puts "2. Set primary after adding all UIDs:"
puts "   # Add UIDs first"
puts "   ctx.add_uid(key, 'Alice <alice@work.com>')"
puts "   ctx.add_uid(key, 'Alice <alice@personal.net>')"
puts "   # Then set primary"
puts "   ctx.set_uid_flag(key, 'Alice <alice@work.com>', 'primary', '1')"
puts ""

puts "3. Use exact string matching:"
puts "   ✗ ctx.set_uid_flag(key, 'alice smith <...>', 'primary', '1')  # Wrong case"
puts "   ✓ ctx.set_uid_flag(key, 'Alice Smith <...>', 'primary', '1')  # Exact match"
puts ""

puts "4. Choose an appropriate primary:"
puts "   • Use an email you actively monitor"
puts "   • Consider professional vs personal contexts"
puts "   • Update when changing roles or jobs"
puts ""

puts "5. Publish changes to keyservers:"
puts "   # After setting flags, publish the updated key"
puts "   # gpg --send-keys <KEYID>"

# Example 10: Use Cases
separator
puts "Example 10: Common Use Cases"
puts "-" * 70

puts "Scenario 1: New job - change primary email"
puts "  • Add new work email"
puts "  • Set new email as primary"
puts "  • Optionally revoke old work email"
puts ""

puts "Scenario 2: Multiple contexts (work/personal)"
puts "  • Keep both emails on the key"
puts "  • Set primary based on current context"
puts "  • Switch primary as needed"
puts ""

puts "Scenario 3: Email consolidation"
puts "  • Add all your email addresses to one key"
puts "  • Set your main email as primary"
puts "  • Others can encrypt to any of your addresses"
puts ""

puts "Scenario 4: Display name preference"
puts "  • Have multiple name formats (full name, initials)"
puts "  • Set preferred format as primary"
puts "  • Controls how your name appears in listings"

# Summary
separator
puts "Summary"
puts "-" * 70
puts ""
puts "Methods for UID Flag Management:"
puts "  • set_uid_flag(key, userid, flag, value)      - Set flag synchronously"
puts "  • set_uid_flag_start(key, userid, flag, value) - Set flag asynchronously"
puts ""
puts "Parameters:"
puts "  • key:    The key to modify (must be secret key)"
puts "  • userid: The exact UID string to modify"
puts "  • flag:   The flag name (currently 'primary' is most common)"
puts "  • value:  '1' to set, '0' or nil to clear"
puts ""
puts "Common Flag:"
puts "  • 'primary' - Marks the UID as the main identity"
puts ""
puts "Requirements:"
puts "  • Secret key with passphrase access"
puts "  • Exact UID string match"
puts "  • Valid flag name"
puts ""
puts "Best Practices:"
puts "  • Always maintain one primary UID"
puts "  • Use exact string matching for UID"
puts "  • Choose appropriate primary for context"
puts "  • Publish updates to keyservers"
puts "  • Set primary after adding multiple UIDs"
puts ""
puts "For more information, see docs/UID_FLAGS.md"

separator
puts "Examples complete!"
puts ""
puts "Note: Most modification examples are commented out to prevent"
puts "      accidental changes to your keyring. Uncomment and modify"
puts "      the code to test with your own keys."
