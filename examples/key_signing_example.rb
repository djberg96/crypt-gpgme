#!/usr/bin/env ruby
# frozen_string_literal: true

# Key Signing and Signature Revocation Examples
#
# This file demonstrates how to use the key signing and signature
# revocation methods in the crypt-gpgme library.

require 'crypt/gpgme'

# Initialize context
ctx = Crypt::GPGME::Context.new

puts "=== Key Signing Examples ==="
puts

# Example 1: Basic Key Signing
puts "Example 1: Sign all user IDs on a key"
puts "-" * 50

begin
  # Get your signing key (must be a secret key)
  my_key = ctx.list_keys("alice@example.com", 1).first

  if my_key
    ctx.add_signer(my_key)

    # Get the key to sign
    their_key = ctx.list_keys("bob@example.com").first

    if their_key
      puts "Signing key: #{my_key.uids.first.uid}"
      puts "Target key: #{their_key.uids.first.uid}"
      puts "Fingerprint: #{their_key.subkeys.first.fpr}"

      # IMPORTANT: In real usage, verify the fingerprint in person!
      # puts "Have you verified this fingerprint in person? (y/n)"
      # answer = gets.chomp
      # if answer.downcase == 'y'
      #   ctx.sign_key(their_key)
      #   puts "✓ Key signed successfully!"
      # else
      #   puts "✗ Signing cancelled - verification required"
      # end

      puts "(Actual signing commented out - requires passphrase)"
    else
      puts "Target key not found"
    end
  else
    puts "Signing key not found"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 2: Sign Specific User ID
puts "Example 2: Sign a specific user ID"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    ctx.add_signer(my_key)

    # List user IDs on the target key
    puts "User IDs on target key:"
    their_key.uids.each_with_index do |uid, i|
      puts "  #{i + 1}. #{uid.uid}"
    end

    # Sign only the first user ID
    if their_key.uids.first
      userid = their_key.uids.first.uid
      puts "\nSigning only: #{userid}"

      # ctx.sign_key(their_key, userid)
      # puts "✓ User ID signed successfully!"

      puts "(Actual signing commented out - requires passphrase)"
    end
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 3: Local Signature (Not Exportable)
puts "Example 3: Create a local signature"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    ctx.add_signer(my_key)

    puts "Creating a local signature (not exported with key)"
    puts "Useful for personal trust markers"

    # Local signatures are not exported
    flags = Crypt::GPGME::GPGME_KEYSIGN_LOCAL

    # ctx.sign_key(their_key, nil, 0, flags)
    # puts "✓ Local signature created!"

    puts "(Actual signing commented out - requires passphrase)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 4: Expiring Signature
puts "Example 4: Create a signature that expires in 1 year"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    ctx.add_signer(my_key)

    # Calculate expiration time (1 year from now)
    one_year = 365 * 24 * 60 * 60
    expires = Time.now.to_i + one_year
    expire_date = Time.at(expires).strftime("%Y-%m-%d")

    puts "Signature will expire on: #{expire_date}"

    # ctx.sign_key(their_key, nil, expires)
    # puts "✓ Expiring signature created!"

    puts "(Actual signing commented out - requires passphrase)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 5: Non-Expiring Signature with Force
puts "Example 5: Non-expiring signature with force flag"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    ctx.add_signer(my_key)

    # Combine flags
    flags = Crypt::GPGME::GPGME_KEYSIGN_NOEXPIRE | Crypt::GPGME::GPGME_KEYSIGN_FORCE

    puts "Creating non-expiring signature with force flag"
    puts "Flags value: #{flags}"

    # ctx.sign_key(their_key, nil, 0, flags)
    # puts "✓ Non-expiring signature created!"

    puts "(Actual signing commented out - requires passphrase)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 6: Asynchronous Key Signing
puts "Example 6: Asynchronous key signing"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    ctx.add_signer(my_key)

    puts "Starting asynchronous signing operation..."

    # ctx.sign_key_start(their_key)
    # puts "Operation started, now waiting..."
    # ctx.wait
    # puts "✓ Asynchronous signing complete!"

    puts "(Actual signing commented out - requires passphrase)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 7: Signature Revocation
puts "Example 7: Revoke a signature"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    puts "Revoking signature on: #{their_key.uids.first.uid}"
    puts "Signed by: #{my_key.uids.first.uid}"

    # ctx.revoke_signature(their_key, my_key)
    # puts "✓ Signature revoked successfully!"

    puts "(Actual revocation commented out - requires passphrase)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 8: Revoke Signature on Specific User ID
puts "Example 8: Revoke signature on specific user ID"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    # Revoke only on first user ID
    if their_key.uids.first
      userid = their_key.uids.first.uid
      puts "Revoking signature only on: #{userid}"

      # ctx.revoke_signature(their_key, my_key, userid)
      # puts "✓ Signature on specific UID revoked!"

      puts "(Actual revocation commented out - requires passphrase)"
    end
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 9: Revoke Using Current Signer
puts "Example 9: Revoke using current signer"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    # Set the current signer
    ctx.add_signer(my_key)

    puts "Using current signer: #{my_key.uids.first.uid}"

    # Pass nil for signing_key to use current signer
    # ctx.revoke_signature(their_key, nil)
    # puts "✓ Signature revoked using current signer!"

    puts "(Actual revocation commented out - requires passphrase)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 10: Complete Workflow
puts "Example 10: Complete signing and export workflow"
puts "-" * 50

begin
  my_key = ctx.list_keys("alice@example.com", 1).first
  their_key = ctx.list_keys("bob@example.com").first

  if my_key && their_key
    ctx.add_signer(my_key)

    puts "Step 1: Verify fingerprint"
    puts "  Fingerprint: #{their_key.subkeys.first.fpr}"
    puts "  (Verify this in person!)"

    puts "\nStep 2: Sign the key"
    # ctx.sign_key(their_key)
    puts "  (Signing commented out)"

    puts "\nStep 3: Export the signed key"
    export_data = Crypt::GPGME::Data.new
    ctx.export(their_key.subkeys.first.fpr, export_data)
    signed_key = export_data.read

    output_file = "/tmp/signed_key_#{Time.now.to_i}.asc"
    File.write(output_file, signed_key)
    puts "  Exported to: #{output_file}"
    puts "  Size: #{signed_key.length} bytes"

    puts "\nStep 4: Send to key owner or upload to key server"
    puts "  (Use gpg --send-keys or email the exported file)"
  end
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end

puts
puts

# Example 11: Error Handling
puts "Example 11: Proper error handling"
puts "-" * 50

def safe_sign_key(ctx, key_to_sign)
  begin
    # Validate inputs
    raise ArgumentError, "Context required" if ctx.nil?
    raise ArgumentError, "Key required" if key_to_sign.nil?

    # Attempt signing
    ctx.sign_key(key_to_sign)

    puts "✓ Success: Key signed"
    true
  rescue ArgumentError => e
    puts "✗ Invalid argument: #{e.message}"
    false
  rescue Crypt::GPGME::Error => e
    puts "✗ GPGME error: #{e.message}"

    # Handle specific error cases
    case e.message
    when /passphrase/i
      puts "  → Check passphrase or gpg-agent"
    when /secret key/i
      puts "  → Signing key not found or not secret"
    when /permission/i
      puts "  → Check key permissions"
    else
      puts "  → General GPGME error"
    end

    false
  rescue => e
    puts "✗ Unexpected error: #{e.class} - #{e.message}"
    false
  end
end

# Test with nil key (will fail gracefully)
puts "Testing error handling with nil key:"
safe_sign_key(ctx, nil)

puts
puts "=== Examples Complete ==="
puts
puts "Note: Most actual signing operations are commented out as they require:"
puts "  1. Valid secret keys with signing capability"
puts "  2. Access to key passphrases"
puts "  3. Proper identity verification"
puts
puts "Uncomment the signing lines to test with real keys."
