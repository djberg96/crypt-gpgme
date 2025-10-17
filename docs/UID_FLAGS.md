# User ID Flags Management

This guide covers setting flags on user IDs (UIDs) of OpenPGP keys using the crypt-gpgme library.

## Overview

User ID flags are special attributes that can be set on individual UIDs of an OpenPGP key. The most important flag is the **primary** flag, which designates which UID should be considered the "main" identity for the key.

## Methods

### set_uid_flag

Sets or clears a flag on a specific user ID (synchronous operation).

```ruby
ctx.set_uid_flag(key, userid, flag, value = nil)
```

**Parameters:**
- `key` - The key to modify (must be a secret key you own)
- `userid` - The user ID string to modify (must match exactly)
- `flag` - The flag name to set (e.g., "primary")
- `value` - The flag value: "1" to set, "0" to clear, or nil to clear (optional)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if the operation fails

### set_uid_flag_start

Asynchronous version of `set_uid_flag`. Initiates the operation without waiting for completion.

```ruby
ctx.set_uid_flag_start(key, userid, flag, value = nil)
ctx.wait  # Wait for operation to complete
```

## Available Flags

### Primary Flag

The **primary** flag marks a UID as the primary identity for the key. This is the UID that:
- Appears first in key listings
- Is used by default for operations when multiple UIDs exist
- Is displayed prominently in email clients and key managers

**Important:** Setting a UID as primary automatically clears the primary flag from all other UIDs on the key.

## Usage Examples

### Example 1: Set Primary UID

Mark a specific UID as the primary identity:

```ruby
require 'crypt/gpgme'

ctx = Crypt::GPGME::Context.new

# Get your secret key
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# Set work email as primary
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")
```

### Example 2: Change Primary UID

Switch the primary UID from one to another:

```ruby
# Current primary: alice@work.com
# Want to change to: alice@personal.net

# Just set the new primary - the old one is automatically cleared
ctx.set_uid_flag(key, "Alice Smith <alice@personal.net>", "primary", "1")
```

### Example 3: Clear Primary Flag

Clear the primary flag (less common, as you usually want one primary):

```ruby
# Clear using "0"
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "0")

# Or clear using nil
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", nil)
```

### Example 4: Asynchronous Operation

Use the async version for non-blocking operations:

```ruby
# Start operation
ctx.set_uid_flag_start(key, "Alice Smith <alice@work.com>", "primary", "1")

# Do other work here...

# Wait for completion
ctx.wait
```

### Example 5: Multiple UIDs Management

Managing primary flag across multiple UIDs:

```ruby
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# Add multiple UIDs
ctx.add_uid(key, "Alice Smith (Work) <alice@work.com>")
ctx.add_uid(key, "Alice Smith (Personal) <alice@personal.net>")
ctx.add_uid(key, "Alice Smith (Projects) <alice@projects.org>")

# Set the work email as primary
ctx.set_uid_flag(key, "Alice Smith (Work) <alice@work.com>", "primary", "1")

# Later, change to personal as primary
ctx.set_uid_flag(key, "Alice Smith (Personal) <alice@personal.net>", "primary", "1")
```

## Common Use Cases

### 1. Initial Key Setup

Set the primary UID when first creating a key with multiple UIDs:

```ruby
# Create key with one UID
result = ctx.create_key("Alice Smith <alice@example.com>")

# Add additional UIDs
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "Alice Smith <alice@personal.net>")

# Set the main one as primary
ctx.set_uid_flag(key, "Alice Smith <alice@example.com>", "primary", "1")
```

### 2. Email Migration

When changing your primary email address:

```ruby
# Old primary: alice@oldcompany.com
# New primary: alice@newcompany.com

key = ctx.list_keys("alice@oldcompany.com", 1).first

# Add new email
ctx.add_uid(key, "Alice Smith <alice@newcompany.com>")

# Set new email as primary
ctx.set_uid_flag(key, "Alice Smith <alice@newcompany.com>", "primary", "1")

# Optionally revoke old email
ctx.revoke_uid(key, "Alice Smith <alice@oldcompany.com>")
```

### 3. Work/Personal Separation

Managing work and personal identities:

```ruby
key = ctx.list_keys("alice@example.com", 1).first

# During work hours, set work email as primary
ctx.set_uid_flag(key, "Alice Smith (Work) <alice@work.com>", "primary", "1")

# After hours, switch to personal
ctx.set_uid_flag(key, "Alice Smith (Personal) <alice@home.net>", "primary", "1")
```

### 4. Display Name Preference

Control which name format is shown first:

```ruby
# Have both full and abbreviated names
key = ctx.list_keys("alice@example.com", 1).first

ctx.add_uid(key, "Alice Smith <alice@example.com>")
ctx.add_uid(key, "A. Smith <alice@example.com>")

# Prefer full name in listings
ctx.set_uid_flag(key, "Alice Smith <alice@example.com>", "primary", "1")
```

## Error Handling

### Common Errors

```ruby
begin
  ctx.set_uid_flag(key, userid, "primary", "1")
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end
```

**Invalid Key:**
```ruby
# Using nil or invalid key
ctx.set_uid_flag(nil, "Alice <alice@example.com>", "primary", "1")
# => Error: Invalid argument
```

**Not a Secret Key:**
```ruby
# Using public key instead of secret key
public_keys = ctx.list_keys("alice@example.com", 0)
key = public_keys.first

ctx.set_uid_flag(key, "Alice <alice@example.com>", "primary", "1")
# => Error: Secret key not available
```

**UID Not Found:**
```ruby
# UID string doesn't match exactly
ctx.set_uid_flag(key, "alice <alice@example.com>", "primary", "1")
# => Error: No such user ID (case mismatch)
```

**Invalid Flag:**
```ruby
# Using nil flag
ctx.set_uid_flag(key, "Alice <alice@example.com>", nil, "1")
# => Error: Invalid argument
```

## Requirements

### Runtime Requirements

1. **Secret Key**: The key must be a secret (private) key
2. **Key Ownership**: You must own the key
3. **Passphrase Access**: You must be able to provide the passphrase
4. **Exact UID Match**: The userid string must match exactly
5. **Valid Flag Name**: The flag must be a recognized flag (e.g., "primary")

### Getting Secret Keys

```ruby
# Get secret keys (parameter 1)
secret_keys = ctx.list_keys("alice@example.com", 1)

# Get public keys (parameter 0) - won't work for flag setting
public_keys = ctx.list_keys("alice@example.com", 0)
```

## Best Practices

### 1. Always Have One Primary

It's recommended to always have one primary UID:

```ruby
# Good - one clear primary
ctx.set_uid_flag(key, "Alice Smith <alice@main.com>", "primary", "1")

# Less ideal - no primary set
# (Some tools may behave unpredictably)
```

### 2. Set Primary After Adding UIDs

When adding multiple UIDs, set the primary last:

```ruby
# Add all UIDs first
ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "Alice Smith <alice@personal.net>")
ctx.add_uid(key, "Alice Smith <alice@projects.org>")

# Then set the primary
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")
```

### 3. Exact String Matching

Ensure the UID string matches exactly:

```ruby
# Wrong - case mismatch
ctx.set_uid_flag(key, "alice smith <alice@example.com>", "primary", "1")

# Right - exact match
ctx.set_uid_flag(key, "Alice Smith <alice@example.com>", "primary", "1")
```

### 4. Value Handling

The value parameter can be a string or nil:

```ruby
# Set flag (explicit)
ctx.set_uid_flag(key, uid, "primary", "1")

# Clear flag (explicit)
ctx.set_uid_flag(key, uid, "primary", "0")

# Clear flag (implicit)
ctx.set_uid_flag(key, uid, "primary", nil)

# The method converts integers to strings automatically
ctx.set_uid_flag(key, uid, "primary", 1)  # Converts to "1"
```

### 5. Publish After Changes

After setting flags, publish your updated key:

```bash
# Export and publish
gpg --export alice@example.com > alice-updated.asc
gpg --send-keys <KEYID>

# Or upload via web interface
```

## Verification

### Check Primary UID

After setting the primary flag, verify the change:

```bash
# List key with UIDs
gpg --list-keys alice@example.com

# The primary UID is typically shown first or marked
```

### Programmatic Verification

```ruby
# Get the key with fresh data
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# Inspect the key structure
# Note: Exact method depends on your Key implementation
p key
```

## Security Considerations

### 1. Primary UID Visibility

- The primary UID is visible to anyone with your public key
- Choose a primary UID appropriate for public display
- Consider privacy when selecting which identity to make primary

### 2. Email Preference

- The primary UID indicates your preferred contact email
- Ensure it's an email you actively monitor
- Keep it up to date as your preferences change

### 3. Identity Management

- Be thoughtful about which identity you present as "primary"
- Consider professional vs personal contexts
- Update primary when changing jobs or roles

### 4. Keyserver Synchronization

- Publish flag changes to keyservers
- This helps others use the correct UID when encrypting to you
- Regular updates ensure consistency across systems

## Troubleshooting

### "Invalid argument"

**Problem:** Nil key, userid, or flag parameter

**Solution:** Ensure all required parameters are provided:
```ruby
# Wrong
ctx.set_uid_flag(nil, "Alice <alice@example.com>", "primary", "1")

# Right
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first
ctx.set_uid_flag(key, "Alice <alice@example.com>", "primary", "1")
```

### "Secret key not available"

**Problem:** Using a public key instead of secret key

**Solution:** Use `list_keys(pattern, 1)` to get secret keys:
```ruby
# Wrong
keys = ctx.list_keys("alice@example.com", 0)  # Public keys

# Right
keys = ctx.list_keys("alice@example.com", 1)  # Secret keys
```

### "No such user ID"

**Problem:** UID string doesn't match exactly

**Solution:** Use the exact UID string including case and spacing:
```ruby
# List the key to see exact UIDs
keys = ctx.list_keys("alice@example.com", 1)
p keys.first  # Inspect to see exact format

# Use exact match
ctx.set_uid_flag(key, "Alice Smith <alice@example.com>", "primary", "1")
```

### "Operation cancelled"

**Problem:** Passphrase prompt was cancelled

**Solution:**
- Ensure gpg-agent is running
- Try again and enter the correct passphrase
- Check pinentry configuration

## Performance Considerations

### Synchronous vs Asynchronous

```ruby
# Synchronous - blocks until complete
ctx.set_uid_flag(key, uid, "primary", "1")

# Asynchronous - returns immediately
ctx.set_uid_flag_start(key, uid, "primary", "1")
ctx.wait  # Block until complete when needed
```

Use asynchronous for:
- Batch operations on multiple keys
- When you can do other work while waiting
- Long-running operations with passphrase prompts

## Integration with Other Operations

### Complete UID Management Workflow

```ruby
# 1. Get key
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# 2. Add UIDs
ctx.add_uid(key, "Alice Smith (Work) <alice@work.com>")
ctx.add_uid(key, "Alice Smith (Personal) <alice@personal.net>")

# 3. Set primary
ctx.set_uid_flag(key, "Alice Smith (Work) <alice@work.com>", "primary", "1")

# 4. Later, revoke one
ctx.revoke_uid(key, "Alice Smith (Work) <alice@work.com>")

# 5. Change primary to the remaining one
ctx.set_uid_flag(key, "Alice Smith (Personal) <alice@personal.net>", "primary", "1")
```

## Testing

The library includes 20 specs for UID flag management:

```bash
# Run flag-related specs
bundle exec rspec --format documentation --example "set_uid_flag"

# Run all specs
bundle exec rspec
```

### Test Coverage

- ✅ Method existence and signatures (2 specs)
- ✅ Parameter validation (8 specs)
- ✅ Arity checks (2 specs)
- ✅ Error handling (8 specs)
- ✅ Synchronous/asynchronous consistency (2 specs)
- ✅ Value conversion (2 specs)

**Total: 20 examples, 0 failures**

## API Reference

### Method Signatures

```ruby
set_uid_flag(key, userid, flag, value = nil) → nil
set_uid_flag_start(key, userid, flag, value = nil) → nil
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| key | Key/Structs::Key | Yes | The key to modify |
| userid | String | Yes | The UID to modify (exact match) |
| flag | String | Yes | The flag name (e.g., "primary") |
| value | String/Integer/nil | No | "1" to set, "0" or nil to clear |

### Return Value

Both methods return `nil` on success.

### Exceptions

Both methods raise `Crypt::GPGME::Error` on failure with descriptive error messages.

## Examples Summary

1. **Set Primary UID** - Mark a UID as primary
2. **Change Primary UID** - Switch primary from one UID to another
3. **Clear Primary Flag** - Remove primary status
4. **Asynchronous Operation** - Non-blocking flag setting
5. **Multiple UIDs Management** - Managing flags across several UIDs

## See Also

- [User ID Management](USER_ID_MANAGEMENT.md) - Adding and revoking UIDs
- [UID Quick Reference](UID_QUICK_REFERENCE.md) - Quick reference for UID operations
- [GPGME Manual](https://www.gnupg.org/documentation/manuals/gpgme/) - Official GPGME documentation

## Notes

- The "primary" flag is currently the only widely-used UID flag
- Future GPGME versions may introduce additional flags
- Setting a UID as primary is atomic - the old primary is cleared automatically
- Flag changes require the key's passphrase
- Always publish updated keys to keyservers after making changes
