# User ID Management Implementation Summary

## Overview

This document summarizes the implementation of user ID (UID) management functionality in the crypt-gpgme library, allowing users to add and revoke user IDs on OpenPGP keys.

## Implemented Methods

### 1. `Context#add_uid(key, userid, reserved = 0)`

Adds a new user ID to an existing OpenPGP key (synchronous operation).

**Parameters:**
- `key` (Key or Structs::Key, required): The key to modify (must be a secret key)
- `userid` (String, required): The user ID to add in the format "Name <email@example.com>"
- `reserved` (Integer, optional): Reserved for future use (default: 0)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if the operation fails

**Example:**
```ruby
key = ctx.list_keys("alice@example.com", 1).first
ctx.add_uid(key, "Alice Smith <alice.smith@work.com>")
```

### 2. `Context#add_uid_start(key, userid, reserved = 0)`

Asynchronous version of `add_uid`. Initiates the operation without waiting for completion.

**Usage:**
```ruby
ctx.add_uid_start(key, "Alice <alice@work.com>")
ctx.wait  # Wait for operation to complete
```

### 3. `Context#revoke_uid(key, userid, reserved = 0)`

Revokes (marks as invalid) a user ID on an OpenPGP key (synchronous operation).

**Parameters:**
- `key` (Key or Structs::Key, required): The key to modify (must be a secret key)
- `userid` (String, required): The user ID to revoke (must match exactly)
- `reserved` (Integer, optional): Reserved for future use (default: 0)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if the operation fails

**Example:**
```ruby
key = ctx.list_keys("alice@example.com", 1).first
ctx.revoke_uid(key, "Alice Smith <old@example.com>")
```

**Note:** Revoked user IDs remain on the key but are marked as invalid.

### 4. `Context#revoke_uid_start(key, userid, reserved = 0)`

Asynchronous version of `revoke_uid`.

**Usage:**
```ruby
ctx.revoke_uid_start(key, "Old Name <old@example.com>")
ctx.wait
```

## User ID Format

User IDs should follow the OpenPGP standard format:

### Basic Format
```
Name <email@example.com>
```

### Format with Comment
```
Name (Comment) <email@example.com>
```

### Examples
- `"Alice Smith <alice@example.com>"` ✓
- `"Bob Jones (Work) <bob@company.com>"` ✓
- `"系統管理員 <admin@example.jp>"` ✓ (UTF-8 supported)
- `"alice@example.com"` ✗ (Missing name and brackets)
- `"Alice"` ✗ (Missing email)

## Common Use Cases

### 1. Multiple Email Addresses

Associate multiple email addresses with one key:

```ruby
ctx = Crypt::GPGME::Context.new
key = ctx.list_keys("alice@example.com", 1).first

ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "Alice Smith <alice@personal.net>")
ctx.add_uid(key, "Alice Smith <alice@opensource.org>")
```

### 2. Name Changes

Handle legal name changes (marriage, etc.):

```ruby
key = ctx.list_keys("alice@example.com", 1).first

# Add new name
ctx.add_uid(key, "Alice Johnson <alice@example.com>")

# Optionally revoke old name
ctx.revoke_uid(key, "Alice Smith <alice@example.com>")
```

### 3. Context Separation

Use comments to distinguish different contexts:

```ruby
ctx.add_uid(key, "Alice Smith (Work) <alice@company.com>")
ctx.add_uid(key, "Alice Smith (Personal) <alice@home.net>")
ctx.add_uid(key, "Alice Smith (Open Source) <alice@oss.org>")
```

### 4. Email Compromise

Revoke compromised email addresses:

```ruby
# Immediately revoke the compromised address
ctx.revoke_uid(key, "Alice Smith <compromised@example.com>")

# Publish the updated key to notify others
# gpg --send-keys <KEYID>
```

## Testing

### Test Coverage

The implementation includes **28 comprehensive specs** covering:

#### `add_uid` (8 specs)
- ✅ Basic functionality
- ✅ Parameter requirements (key and userid required)
- ✅ Optional parameter (reserved)
- ✅ Method arity verification (-3: 2 required, 1 optional)
- ✅ Error handling (nil key)
- ✅ Error handling (nil userid)

#### `add_uid_start` (6 specs)
- ✅ Basic asynchronous functionality
- ✅ Parameter requirements
- ✅ Method signature consistency with synchronous version
- ✅ Async behavior verification
- ✅ Error handling (nil key)
- ✅ Error handling (nil userid)

#### `revoke_uid` (8 specs)
- ✅ Basic functionality
- ✅ Parameter requirements (key and userid required)
- ✅ Optional parameter (reserved)
- ✅ Method arity verification (-3: 2 required, 1 optional)
- ✅ Error handling (nil key)
- ✅ Error handling (nil userid)

#### `revoke_uid_start` (6 specs)
- ✅ Basic asynchronous functionality
- ✅ Parameter requirements
- ✅ Method signature consistency with synchronous version
- ✅ Async behavior verification
- ✅ Error handling (nil key)
- ✅ Error handling (nil userid)

### Running Tests

```bash
# Run all UID management specs
bundle exec rspec --format documentation --example "uid"

# Run all specs
bundle exec rspec
```

### Current Test Results

```
28 examples for add_uid/revoke_uid methods
───────────────────────────────────────────
28 examples, 0 failures

Total suite: 239 examples, 0 failures
```

## Implementation Details

### FFI Bindings

The GPGME functions were already bound in `functions.rb`:

```ruby
attach_function :gpgme_op_adduid,
  [Structs::Context, Structs::Key, :string, :uint],
  :uint

attach_function :gpgme_op_adduid_start,
  [Structs::Context, Structs::Key, :string, :uint],
  :uint

attach_function :gpgme_op_revuid,
  [Structs::Context, Structs::Key, :string, :uint],
  :uint

attach_function :gpgme_op_revuid_start,
  [Structs::Context, Structs::Key, :string, :uint],
  :uint
```

### Error Handling

All methods raise `Crypt::GPGME::Error` on failure:

```ruby
if err != GPG_ERR_NO_ERROR
  errstr = gpgme_strerror(err)
  raise Crypt::GPGME::Error, "gpgme_op_adduid failed: #{errstr}"
end
```

Common error conditions:
- Invalid key parameter (nil or invalid)
- Not a secret key
- Invalid user ID format
- Permission denied (passphrase required)
- User ID already exists (for add_uid)
- User ID not found (for revoke_uid)

### Key Parameter Handling

The methods accept both Key and Structs::Key objects:

```ruby
key_struct = key.is_a?(Structs::Key) ? key : key.instance_variable_get(:@key)
```

## Requirements

### Runtime Requirements

1. **Secret Key**: The key must be a secret (private) key, not a public key
2. **Key Ownership**: You must own the key (have the private key)
3. **Passphrase Access**: You must be able to provide the key's passphrase
4. **Valid Format**: User ID must be in valid OpenPGP format

### Checking Requirements

```ruby
# Get secret keys only (parameter 1)
secret_keys = ctx.list_keys("alice@example.com", 1)

# Get public keys only (parameter 0)
public_keys = ctx.list_keys("alice@example.com", 0)

# Only secret keys can be modified
if secret_keys.empty?
  puts "No secret key available for modification"
end
```

## Security Considerations

### 1. User ID Privacy

- User IDs are **public information**
- Anyone with your public key can see all UIDs (including revoked ones)
- Don't include sensitive information in UIDs

### 2. Revocation vs Deletion

- Revoked UIDs are **not deleted** from the key
- They remain visible but marked as invalid
- This is intentional - it notifies others not to use that UID
- Never try to hide a compromised UID

### 3. Email Address Control

- Only add email addresses you control
- Revoke UIDs immediately when you lose control of an email
- Consider using email aliases for different contexts

### 4. Publishing Changes

After modifying UIDs, publish your updated key:

```bash
# Export and publish
gpg --export alice@example.com > alice-updated.asc
gpg --send-keys <KEYID>

# Or use keyserver web interface
# https://keys.openpgp.org
```

## Best Practices

### 1. Consistent Naming

Use the same name format across all UIDs:

```ruby
# Good - consistent
ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "Alice Smith <alice@personal.net>")

# Bad - inconsistent
ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "A. Smith <alice@personal.net>")
```

### 2. Use Comments for Context

When multiple UIDs share the same email:

```ruby
ctx.add_uid(key, "Alice Smith (Work) <alice@example.com>")
ctx.add_uid(key, "Alice Smith (Personal) <alice@example.com>")
```

### 3. Prompt Revocation

Revoke UIDs immediately when circumstances change:

```ruby
# Lost control of email
ctx.revoke_uid(key, "Alice <old-job@company.com>")

# Email compromised
ctx.revoke_uid(key, "Alice <compromised@example.com>")
```

### 4. Exact String Matching

For revocation, the UID string must match exactly:

```ruby
# Check the exact format first
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first
# Inspect key structure to see exact UID strings

# Then revoke with exact match
ctx.revoke_uid(key, "Alice Smith <alice@example.com>")  # Must match exactly
```

### 5. Verify Before Publishing

After changes, verify the key state before publishing:

```bash
# List the updated key
gpg --list-keys alice@example.com

# Export to verify
gpg --export alice@example.com | gpg --list-packets

# Then publish
gpg --send-keys <KEYID>
```

## Documentation

Comprehensive documentation has been created:

### Documents Created

1. **`docs/USER_ID_MANAGEMENT.md`** (~600 lines)
   - Complete user guide
   - All methods documented
   - Common use cases
   - Error handling
   - Security considerations
   - Troubleshooting

2. **`examples/uid_management_example.rb`** (~400 lines)
   - 9 complete examples
   - Error handling demonstrations
   - Best practices
   - Complete workflow example
   - Safety comments (examples commented out by default)

3. **`UID_MANAGEMENT_SUMMARY.md`** (this file)
   - Implementation overview
   - Test coverage
   - Technical details

### YARD Documentation

All methods include comprehensive YARD documentation in the source:

- Parameter descriptions with types
- Return values
- Raised exceptions
- Usage examples
- Important notes and warnings

## Troubleshooting

### "Invalid argument"

**Cause:** Nil key or invalid key parameter

**Solution:**
```ruby
# Ensure you have a valid key
keys = ctx.list_keys("alice@example.com", 1)
raise "No key found" if keys.empty?
key = keys.first
ctx.add_uid(key, "Alice <alice@work.com>")
```

### "Secret key not available"

**Cause:** Trying to modify a public key

**Solution:**
```ruby
# Use 1 to get secret keys
secret_keys = ctx.list_keys("alice@example.com", 1)  # Not 0
```

### "Invalid user ID"

**Cause:** Malformed UID string

**Solution:**
```ruby
# Wrong
ctx.add_uid(key, "alice@example.com")

# Right
ctx.add_uid(key, "Alice <alice@example.com>")
```

### "No such user ID"

**Cause:** UID string doesn't match exactly (for revocation)

**Solution:**
```ruby
# List the key to see exact UID format
keys = ctx.list_keys("alice@example.com", 1)
p keys.first  # Inspect to see exact UIDs

# Use exact string including case and spacing
ctx.revoke_uid(key, "Alice Smith <alice@example.com>")
```

## Performance Considerations

### Synchronous vs Asynchronous

- **Synchronous** (`add_uid`, `revoke_uid`): Block until complete
- **Asynchronous** (`add_uid_start`, `revoke_uid_start`): Return immediately

Use asynchronous for:
- Multiple operations in sequence
- Long-running batch operations
- When you need to perform other work

```ruby
# Asynchronous batch operation
keys.each do |key|
  ctx.add_uid_start(key, "User <user@example.com>")
end

# Wait for all to complete
ctx.wait
```

## Files Modified

### Source Files
- `lib/crypt/gpgme/context.rb` - Added 4 new methods (~150 lines with docs)

### Test Files
- `spec/context_spec.rb` - Added 28 specs

### Documentation Files
- `docs/USER_ID_MANAGEMENT.md` - Complete user guide (~600 lines)
- `examples/uid_management_example.rb` - Working examples (~400 lines)
- `UID_MANAGEMENT_SUMMARY.md` - Implementation summary (this file)

### Total Additions
- ~1,200 lines of code, documentation, and examples

## Summary

✅ All requested functionality implemented
✅ 28 comprehensive specs (all passing)
✅ Full YARD documentation
✅ Comprehensive user guide
✅ Working example script with 9 examples
✅ Best practices documented
✅ Security considerations documented
✅ Troubleshooting guide included

The user ID management implementation provides a complete, well-tested, and well-documented interface for adding and revoking user IDs on OpenPGP keys, with full support for both synchronous and asynchronous operations.

## Integration with Existing Features

This implementation builds on the existing codebase:

- Uses existing FFI bindings (already present in `functions.rb`)
- Follows established patterns from other methods
- Integrates with existing error handling
- Compatible with existing Context methods
- Works with existing Key structures

The implementation is consistent with:
- `set_expire` methods (key expiration)
- `set_owner_trust` methods (owner trust)
- `create_key`/`create_subkey` methods (key creation)

## Version Compatibility

Works with:
- GPGME 1.8.0 and later (adduid/revuid support)
- Ruby 2.5+ (FFI compatibility)
- GPG 2.0.12 and later

## Future Enhancements

Potential future additions:
- `set_uid_flag` method (already has FFI binding)
- Primary UID selection
- UID certification level control
- Batch UID operations helper
- UID validation before adding
