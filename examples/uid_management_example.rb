#!/usr/bin/env ruby
# frozen_string_literal: true

# User ID Management Example
#
# This script demonstrates how to add and revoke user IDs on OpenPGP keys
# using the crypt-gpgme library.
#
# WARNING: This script contains examples that will modify keys in your keyring.
# The actual modification calls are commented out by default.

require 'crypt/gpgme'

def separator
  puts "\n" + "=" * 70 + "\n\n"
end

puts "User ID Management Examples"
puts "=" * 70

# Initialize context
ctx = Crypt::GPGME::Context.new
ctx.armor = true

# Example 1: List existing user IDs on a key
separator
puts "Example 1: Viewing User IDs on a Key"
puts "-" * 70

# Replace with your own email address for testing
test_email = "alice@example.com"

puts "Looking for keys matching: #{test_email}"
keys = ctx.list_keys(test_email, 1)  # 1 = secret keys

if keys.empty?
  puts "No secret keys found for #{test_email}"
  puts "Note: You need a secret key to add/revoke UIDs"
else
  key = keys.first
  puts "Found key:"
  puts "  Fingerprint: #{key[:fingerprint]}"
  puts "  User IDs:"
  # Note: Exact structure may vary - inspect the key hash
  p key
end

# Example 2: Adding a new user ID
separator
puts "Example 2: Adding a New User ID"
puts "-" * 70

puts "Adding a new user ID to a key:"
puts "  Original: Alice Smith <alice@example.com>"
puts "  Adding:   Alice Smith <alice.smith@work.com>"
puts ""

# UNCOMMENT THE FOLLOWING LINES TO ACTUALLY ADD A UID:
# keys = ctx.list_keys("alice@example.com", 1)
# if !keys.empty?
#   key = keys.first
#   begin
#     ctx.add_uid(key, "Alice Smith <alice.smith@work.com>")
#     puts "✓ Successfully added new user ID"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# end

puts "(Uncomment the code to test actual UID addition)"

# Example 3: Adding multiple user IDs
separator
puts "Example 3: Adding Multiple User IDs"
puts "-" * 70

puts "Adding multiple email addresses to one key:"

uids_to_add = [
  "Alice Smith <alice@work.com>",
  "Alice Smith <alice@personal.net>",
  "Alice Smith <alice@opensource.org>"
]

uids_to_add.each do |uid|
  puts "  - #{uid}"
end

# UNCOMMENT TO TEST:
# keys = ctx.list_keys("alice@example.com", 1)
# if !keys.empty?
#   key = keys.first
#   uids_to_add.each do |uid|
#     begin
#       ctx.add_uid(key, uid)
#       puts "✓ Added: #{uid}"
#     rescue Crypt::GPGME::Error => e
#       puts "✗ Error adding #{uid}: #{e.message}"
#     end
#   end
# end

puts "(Uncomment the code to test actual UID addition)"

# Example 4: Adding UIDs with comments
separator
puts "Example 4: Using Comments in User IDs"
puts "-" * 70

puts "Adding user IDs with contextual comments:"

uids_with_comments = [
  "Alice Smith (Work) <alice@company.com>",
  "Alice Smith (Personal) <alice@home.net>",
  "Alice Smith (Open Source Projects) <alice@dev.org>"
]

uids_with_comments.each do |uid|
  puts "  - #{uid}"
end

# UNCOMMENT TO TEST:
# keys = ctx.list_keys("alice@example.com", 1)
# if !keys.empty?
#   key = keys.first
#   uids_with_comments.each do |uid|
#     begin
#       ctx.add_uid(key, uid)
#       puts "✓ Added: #{uid}"
#     rescue Crypt::GPGME::Error => e
#       puts "✗ Error: #{e.message}"
#     end
#   end
# end

puts "(Uncomment the code to test)"

# Example 5: Revoking a user ID
separator
puts "Example 5: Revoking a User ID"
puts "-" * 70

puts "Revoking a user ID when you no longer control an email address:"
uid_to_revoke = "Alice Smith <old-email@former-company.com>"
puts "  Revoking: #{uid_to_revoke}"

# UNCOMMENT TO TEST:
# keys = ctx.list_keys("alice@example.com", 1)
# if !keys.empty?
#   key = keys.first
#   begin
#     ctx.revoke_uid(key, uid_to_revoke)
#     puts "✓ Successfully revoked user ID"
#     puts "  Note: The UID is not deleted, just marked as revoked"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# end

puts "(Uncomment the code to test actual UID revocation)"

# Example 6: Asynchronous operations
separator
puts "Example 6: Asynchronous UID Operations"
puts "-" * 70

puts "Using async methods for non-blocking operations:"

# UNCOMMENT TO TEST:
# keys = ctx.list_keys("alice@example.com", 1)
# if !keys.empty?
#   key = keys.first
#
#   # Start adding UID asynchronously
#   begin
#     ctx.add_uid_start(key, "Alice Smith <async@example.com>")
#     puts "Started adding UID asynchronously..."
#
#     # Do other work here...
#     puts "Waiting for operation to complete..."
#     ctx.wait
#
#     puts "✓ UID addition complete"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
#
#   # Start revoking UID asynchronously
#   begin
#     ctx.revoke_uid_start(key, "Alice Smith <async@example.com>")
#     puts "Started revoking UID asynchronously..."
#     ctx.wait
#     puts "✓ UID revocation complete"
#   rescue Crypt::GPGME::Error => e
#     puts "✗ Error: #{e.message}"
#   end
# end

puts "(Uncomment the code to test)"

# Example 7: Error handling
separator
puts "Example 7: Error Handling"
puts "-" * 70

puts "Handling common errors:"

# Error 1: Nil key
puts "\n1. Trying to add UID with nil key:"
begin
  ctx.add_uid(nil, "Test <test@example.com>")
rescue Crypt::GPGME::Error => e
  puts "   ✓ Caught error: #{e.message}"
end

# Error 2: Public key instead of secret key
puts "\n2. Trying to modify a public key:"
public_keys = ctx.list_keys("someone@example.com", 0)  # 0 = public keys
unless public_keys.empty?
  begin
    ctx.add_uid(public_keys.first, "Test <test@example.com>")
  rescue Crypt::GPGME::Error => e
    puts "   ✓ Caught error: #{e.message}"
  end
else
  puts "   (No public keys to test with)"
end

# Error 3: Invalid user ID format
puts "\n3. Trying to add malformed UID:"
keys = ctx.list_keys(nil, 1)
unless keys.empty?
  begin
    # Missing angle brackets around email
    ctx.add_uid(keys.first, "test@example.com")
  rescue Crypt::GPGME::Error => e
    puts "   ✓ Caught error: #{e.message}"
  end
end

# Example 8: Best practices
separator
puts "Example 8: Best Practices"
puts "-" * 70

puts "Recommended patterns for UID management:"
puts ""

puts "1. Consistent naming across UIDs:"
puts "   ✓ Alice Smith <alice@work.com>"
puts "   ✓ Alice Smith <alice@personal.net>"
puts "   ✗ A. Smith <alice@work.com>  # Inconsistent"
puts ""

puts "2. Use comments for context:"
puts "   ✓ Alice Smith (Work) <alice@example.com>"
puts "   ✓ Alice Smith (Personal) <alice@example.com>"
puts ""

puts "3. Revoke promptly when losing control:"
puts "   # Old job email"
puts "   ctx.revoke_uid(key, 'Alice <old@former-job.com>')"
puts ""

puts "4. Verify the email format:"
puts "   ✓ Name <email@example.com>"
puts "   ✓ Name (Comment) <email@example.com>"
puts "   ✗ email@example.com  # Missing name"
puts "   ✗ Name email@example.com  # Missing brackets"

# Example 9: Complete workflow
separator
puts "Example 9: Complete UID Management Workflow"
puts "-" * 70

puts "A complete example of managing UIDs through a lifecycle:"
puts ""
puts "# 1. Start with a new key"
puts "keys = ctx.list_keys('alice@example.com', 1)"
puts "key = keys.first"
puts ""
puts "# 2. Add work email"
puts "ctx.add_uid(key, 'Alice Smith (Work) <alice@work.com>')"
puts ""
puts "# 3. Add project email"
puts "ctx.add_uid(key, 'Alice Smith (Projects) <alice@projects.org>')"
puts ""
puts "# 4. Change jobs - revoke old work email"
puts "ctx.revoke_uid(key, 'Alice Smith (Work) <alice@work.com>')"
puts ""
puts "# 5. Add new work email"
puts "ctx.add_uid(key, 'Alice Smith (Work) <alice@newjob.com>')"
puts ""
puts "# 6. Export and publish updated key"
puts "# gpg --export alice@example.com | gpg --send-keys"

# Summary
separator
puts "Summary"
puts "-" * 70
puts ""
puts "Methods for UID Management:"
puts "  • add_uid(key, userid, reserved=0)      - Add a UID synchronously"
puts "  • add_uid_start(key, userid, reserved)  - Add a UID asynchronously"
puts "  • revoke_uid(key, userid, reserved=0)   - Revoke a UID synchronously"
puts "  • revoke_uid_start(key, userid, reserved) - Revoke a UID asynchronously"
puts ""
puts "Requirements:"
puts "  • Key must be a secret key (not public)"
puts "  • You must have access to the key's passphrase"
puts "  • UID format: 'Name <email@example.com>'"
puts "  • Revocation requires exact UID string match"
puts ""
puts "Best Practices:"
puts "  • Always include email in angle brackets"
puts "  • Use consistent name formatting"
puts "  • Revoke UIDs promptly when you lose control of an email"
puts "  • Consider using comments for different contexts"
puts "  • Publish updated keys to keyservers after changes"
puts ""
puts "For more information, see docs/USER_ID_MANAGEMENT.md"

separator
puts "Examples complete!"
puts ""
puts "Note: Most modification examples are commented out to prevent"
puts "      accidental changes to your keyring. Uncomment and modify"
puts "      the code to test with your own keys."
