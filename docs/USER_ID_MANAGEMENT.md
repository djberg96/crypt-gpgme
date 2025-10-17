# User ID Management

This guide covers adding and revoking user IDs (UIDs) on OpenPGP keys using the crypt-gpgme library.

## Overview

User IDs in OpenPGP are strings that identify the key owner, typically in the format:
```
Name <email@example.com>
```

or with a comment:
```
Name (Comment) <email@example.com>
```

A single key can have multiple user IDs, which is useful when you want the same key associated with:
- Multiple email addresses
- Different names (e.g., maiden name, nickname)
- Work and personal identities

## Methods

### add_uid

Adds a new user ID to an existing key (synchronous operation).

```ruby
ctx.add_uid(key, userid, reserved = 0)
```

**Parameters:**
- `key` - The key to modify (must be a secret key you own)
- `userid` - The user ID string to add
- `reserved` - Reserved parameter, must be 0 (optional)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if the operation fails

### add_uid_start

Asynchronous version of `add_uid`. Initiates the operation without waiting for completion.

```ruby
ctx.add_uid_start(key, userid, reserved = 0)
ctx.wait  # Wait for operation to complete
```

### revoke_uid

Revokes (marks as invalid) a user ID on a key (synchronous operation).

```ruby
ctx.revoke_uid(key, userid, reserved = 0)
```

**Parameters:**
- `key` - The key to modify (must be a secret key you own)
- `userid` - The user ID string to revoke (must match exactly)
- `reserved` - Reserved parameter, must be 0 (optional)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if the operation fails

**Note:** Revoked user IDs are not deleted but marked as invalid. They remain visible on the key.

### revoke_uid_start

Asynchronous version of `revoke_uid`.

```ruby
ctx.revoke_uid_start(key, userid, reserved = 0)
ctx.wait  # Wait for operation to complete
```

## User ID Format

### Basic Format

```
Name <email@example.com>
```

Examples:
- `"Alice Smith <alice@example.com>"`
- `"Bob Jones <bob.jones@company.com>"`
- `"系统管理员 <admin@example.jp>"` (UTF-8 supported)

### Format with Comment

```
Name (Comment) <email@example.com>
```

Examples:
- `"Alice Smith (Work) <alice@example.com>"`
- `"Bob Jones (Personal) <bob@home.net>"`
- `"Admin User (Production Server) <admin@example.com>"`

### Best Practices

1. **Always include an email address** in angle brackets
2. **Use valid email addresses** that you control
3. **Be consistent** with capitalization and spacing
4. **Use UTF-8** for international characters
5. **Keep it professional** - this information is public

## Common Use Cases

### 1. Adding a Secondary Email Address

When you have multiple email addresses and want to use the same key:

```ruby
require 'crypt/gpgme'

ctx = Crypt::GPGME::Context.new

# Get your secret key
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# Add a work email
ctx.add_uid(key, "Alice Smith <alice.smith@work.com>")

# Add a personal email
ctx.add_uid(key, "Alice Smith <alice@personal.net>")
```

### 2. Changing Your Name

When you change your name (marriage, legal name change, etc.):

```ruby
# Get your key
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# Add new name
ctx.add_uid(key, "Alice Johnson <alice@example.com>")

# Optionally revoke old name (or keep both)
ctx.revoke_uid(key, "Alice Smith <alice@example.com>")
```

### 3. Consolidating Multiple Keys

When migrating from multiple keys to a single key:

```ruby
# Add all your email addresses to one key
main_key = ctx.list_keys("alice@example.com", 1).first

ctx.add_uid(main_key, "Alice <alice@work.com>")
ctx.add_uid(main_key, "Alice <alice@school.edu>")
ctx.add_uid(main_key, "Alice <alice@personal.net>")
```

### 4. Separating Work and Personal

Using comments to distinguish contexts:

```ruby
key = ctx.list_keys("alice@example.com", 1).first

ctx.add_uid(key, "Alice Smith (Work) <alice.smith@company.com>")
ctx.add_uid(key, "Alice Smith (Personal) <alice@personal.net>")
ctx.add_uid(key, "Alice Smith (Open Source) <alice@opensource.org>")
```

### 5. Revoking a Compromised Email

When an email account is compromised or you no longer control it:

```ruby
key = ctx.list_keys("alice@example.com", 1).first

# Revoke the compromised email address
ctx.revoke_uid(key, "Alice Smith <old-compromised@example.com>")

# Publish the updated key to keyservers
# (This notifies others that the UID is no longer valid)
```

## Asynchronous Operations

For long-running operations or to perform other work while the operation completes:

```ruby
# Start adding UID asynchronously
ctx.add_uid_start(key, "Alice <new@example.com>")

# Do other work here...

# Wait for completion
ctx.wait

# Similarly for revocation
ctx.revoke_uid_start(key, "Alice <old@example.com>")
ctx.wait
```

## Error Handling

Common errors and how to handle them:

### Invalid Key

```ruby
begin
  ctx.add_uid(nil, "Alice <alice@example.com>")
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
  # Error: gpgme_op_adduid failed: Invalid argument
end
```

### Not a Secret Key

```ruby
# Using a public key instead of secret key
public_keys = ctx.list_keys("alice@example.com", 0)  # 0 = public keys
key = public_keys.first

begin
  ctx.add_uid(key, "Alice <new@example.com>")
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
  # Error: Secret key not available
end
```

### Passphrase Required

If your key has a passphrase, you'll need to configure the pinentry program:

```ruby
ctx = Crypt::GPGME::Context.new

# Set up passphrase callback or use gpg-agent
# The operation will prompt for the passphrase automatically

key = ctx.list_keys("alice@example.com", 1).first
ctx.add_uid(key, "Alice <new@example.com>")
```

### UID Already Exists

Adding a duplicate UID may succeed or fail depending on GPGME version:

```ruby
begin
  ctx.add_uid(key, "Alice <alice@example.com>")  # Original UID
  ctx.add_uid(key, "Alice <alice@example.com>")  # Duplicate
rescue Crypt::GPGME::Error => e
  puts "UID may already exist: #{e.message}"
end
```

### UID Not Found (Revocation)

The UID string must match exactly:

```ruby
# This will fail - wrong case
ctx.revoke_uid(key, "alice smith <alice@example.com>")

# This will work - exact match
ctx.revoke_uid(key, "Alice Smith <alice@example.com>")
```

## Verifying Changes

After adding or revoking UIDs, verify the changes:

```ruby
# Refresh the key list
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# Check the key's user IDs
puts "User IDs on key:"
# Note: The exact structure depends on your Key hash implementation
# You may need to inspect the key structure
p key
```

## Publishing Updated Keys

After modifying UIDs, publish your key to keyservers so others can see the changes:

```bash
# Export your public key
gpg --export alice@example.com > alice-updated.asc

# Upload to a keyserver
gpg --send-keys <KEYID>

# Or upload via web interface
# Most keyservers: https://keys.openpgp.org
```

## Security Considerations

### 1. Revocation vs Deletion

- **Revoked UIDs** remain on the key but are marked invalid
- This is intentional - it notifies others that the UID should not be used
- Never try to hide a compromised UID by deleting it

### 2. Privacy

- User IDs are public information
- Anyone with your public key can see all UIDs (including revoked ones)
- Don't include private information in UIDs

### 3. Email Address Control

- Only add email addresses you control
- If you lose control of an email, revoke the UID immediately
- Consider using email aliases for different contexts

### 4. Key Signing

- When someone signs your key, they're certifying all non-revoked UIDs
- Revoke UIDs before getting new signatures if you want them excluded
- Or ask signers to certify specific UIDs only

## Troubleshooting

### "Secret key not available"

**Problem:** Trying to modify a public key

**Solution:** Use `list_keys(pattern, 1)` to get secret keys:
```ruby
# Wrong - gets public keys
keys = ctx.list_keys("alice@example.com", 0)

# Right - gets secret keys
keys = ctx.list_keys("alice@example.com", 1)
```

### "Invalid user ID"

**Problem:** Malformed user ID string

**Solution:** Ensure proper format with email in angle brackets:
```ruby
# Wrong
ctx.add_uid(key, "alice@example.com")
ctx.add_uid(key, "Alice")

# Right
ctx.add_uid(key, "Alice <alice@example.com>")
```

### "Operation cancelled"

**Problem:** Passphrase entry was cancelled

**Solution:**
- Try again and enter the correct passphrase
- Check that gpg-agent is running
- Configure pinentry properly

### "No such user ID"

**Problem:** UID string doesn't match exactly when revoking

**Solution:**
- Use the exact string, including spacing and case
- List the key's UIDs first to see the exact format
- Copy and paste the UID string if possible

## Best Practices

### 1. Maintain Consistency

Keep the same name format across all UIDs:
```ruby
# Good
ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "Alice Smith <alice@personal.net>")

# Inconsistent
ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "A. Smith <alice@personal.net>")
```

### 2. Use Descriptive Comments

When having multiple UIDs with the same email:
```ruby
ctx.add_uid(key, "Alice Smith (Work) <alice@example.com>")
ctx.add_uid(key, "Alice Smith (Personal) <alice@example.com>")
```

### 3. Revoke Promptly

When you no longer control an email address:
```ruby
# Revoke immediately
ctx.revoke_uid(key, "Alice <old-job@former-company.com>")

# Then publish the updated key
```

### 4. Backup Before Major Changes

Before making significant UID changes:
```bash
gpg --export-secret-keys alice@example.com > backup.asc
```

### 5. Document Your UIDs

Keep a record of which UIDs you've added and why:
```ruby
# Primary email
ctx.add_uid(key, "Alice Smith <alice@example.com>")

# Work email - added 2024-03-15
ctx.add_uid(key, "Alice Smith <alice.smith@work.com>")

# Project email - added 2024-06-20
ctx.add_uid(key, "Alice Smith <alice@opensource.org>")
```

## Testing

The library includes 28 specs for UID management:

```bash
# Run all UID-related specs
bundle exec rspec --format documentation --example "uid"

# Run all specs
bundle exec rspec
```

Test coverage:
- ✅ Method existence and signatures
- ✅ Parameter validation
- ✅ Error handling
- ✅ Synchronous and asynchronous versions
- ✅ Nil parameter handling

## See Also

- [GPGME Manual](https://www.gnupg.org/documentation/manuals/gpgme/) - Official GPGME documentation
- [OpenPGP Best Practices](https://riseup.net/en/security/message-security/openpgp/best-practices)
- [Key Management Guide](https://wiki.debian.org/Keysigning)

## Examples

See `examples/uid_management_example.rb` for complete, runnable examples of UID management operations.
