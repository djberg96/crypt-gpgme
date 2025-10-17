# UID Flag Management Implementation Summary

## Overview

This document summarizes the implementation of user ID (UID) flag management functionality in the crypt-gpgme library, allowing users to set and clear flags on user IDs of OpenPGP keys.

## Implemented Methods

### 1. `Context#set_uid_flag(key, userid, flag, value = nil)`

Sets or clears a flag on a specific user ID (synchronous operation).

**Parameters:**
- `key` (Key or Structs::Key, required): The key to modify (must be a secret key)
- `userid` (String, required): The user ID to modify (must match exactly)
- `flag` (String, required): The flag name to set (e.g., "primary")
- `value` (String/Integer/nil, optional): "1" to set, "0" or nil to clear (default: nil)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if the operation fails

**Example:**
```ruby
key = ctx.list_keys("alice@example.com", 1).first
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")
```

### 2. `Context#set_uid_flag_start(key, userid, flag, value = nil)`

Asynchronous version of `set_uid_flag`. Initiates the operation without waiting for completion.

**Usage:**
```ruby
ctx.set_uid_flag_start(key, "Alice <alice@work.com>", "primary", "1")
ctx.wait  # Wait for operation to complete
```

## The Primary Flag

The most important and commonly used flag is **"primary"**, which:
- Marks a UID as the main identity for the key
- Appears first in key listings
- Is used by default in email clients
- Indicates the preferred contact email
- **Automatically clears** the primary flag from other UIDs when set

## Testing

### Test Coverage

The implementation includes **20 comprehensive specs** covering:

#### `set_uid_flag` (12 specs)
- ✅ Basic functionality
- ✅ Parameter requirements (key, userid, flag required)
- ✅ Optional parameter (value)
- ✅ Method arity verification (-4: 3 required, 1 optional)
- ✅ Error handling (nil key)
- ✅ Error handling (nil userid)
- ✅ Error handling (nil flag)
- ✅ Nil value parameter acceptance
- ✅ Value type conversion (integer to string)

#### `set_uid_flag_start` (8 specs)
- ✅ Basic asynchronous functionality
- ✅ Parameter requirements
- ✅ Method signature consistency with synchronous version
- ✅ Async behavior verification
- ✅ Error handling (nil key)
- ✅ Error handling (nil userid)
- ✅ Error handling (nil flag)
- ✅ Nil value parameter acceptance

### Running Tests

```bash
# Run all UID flag specs
bundle exec rspec --format documentation --example "set_uid_flag"

# Run all specs
bundle exec rspec
```

### Current Test Results

```
20 examples for set_uid_flag methods
────────────────────────────────────
20 examples, 0 failures

Total suite: 259 examples, 0 failures
```

## Implementation Details

### FFI Bindings

The GPGME functions were already bound in `functions.rb`:

```ruby
attach_function :gpgme_op_set_uid_flag,
  [Structs::Context, Structs::Key, :string, :string, :string],
  :uint

attach_function :gpgme_op_set_uid_flag_start,
  [Structs::Context, Structs::Key, :string, :string, :string],
  :uint
```

### Value Conversion

The methods handle type conversion for the value parameter:

```ruby
value_str = value.nil? ? nil : value.to_s
```

This allows users to pass:
- String values: `"1"`, `"0"`
- Integer values: `1`, `0` (automatically converted to strings)
- Nil value: `nil` (to clear the flag)

### Error Handling

All methods raise `Crypt::GPGME::Error` on failure:

```ruby
if err != GPG_ERR_NO_ERROR
  errstr = gpgme_strerror(err)
  raise Crypt::GPGME::Error, "gpgme_op_set_uid_flag failed: #{errstr}"
end
```

Common error conditions:
- Invalid key parameter (nil or invalid)
- Not a secret key
- Invalid user ID (nil or doesn't match)
- Invalid flag name (nil or unrecognized)
- Permission denied (passphrase required)
- User ID not found

## Common Use Cases

### 1. Set Primary UID

Mark a specific UID as the primary identity:

```ruby
ctx = Crypt::GPGME::Context.new
key = ctx.list_keys("alice@example.com", 1).first
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")
```

### 2. Change Primary UID

Switch the primary from one UID to another:

```ruby
# This automatically clears the old primary
ctx.set_uid_flag(key, "Alice Smith <alice@personal.net>", "primary", "1")
```

### 3. Clear Primary Flag

Remove the primary flag (less common):

```ruby
# Using "0"
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "0")

# Using nil
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", nil)
```

### 4. Email Migration

When changing primary email address:

```ruby
# Add new email
ctx.add_uid(key, "Alice Smith <alice@newjob.com>")

# Set as primary
ctx.set_uid_flag(key, "Alice Smith <alice@newjob.com>", "primary", "1")

# Optionally revoke old
ctx.revoke_uid(key, "Alice Smith <alice@oldjob.com>")
```

## Requirements

### Runtime Requirements

1. **Secret Key**: The key must be a secret (private) key
2. **Key Ownership**: You must own the key
3. **Passphrase Access**: You must be able to provide the passphrase
4. **Exact UID Match**: The userid string must match exactly
5. **Valid Flag**: The flag must be recognized (e.g., "primary")

### Getting Secret Keys

```ruby
# Get secret keys (parameter 1)
secret_keys = ctx.list_keys("alice@example.com", 1)

# Get public keys (parameter 0) - won't work for flag setting
public_keys = ctx.list_keys("alice@example.com", 0)
```

## Best Practices

### 1. Always Maintain One Primary

Have exactly one primary UID at all times:

```ruby
# Good - one clear primary
ctx.set_uid_flag(key, "Alice <alice@main.com>", "primary", "1")

# Less ideal - no primary
# (May cause unpredictable behavior in some tools)
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

The UID must match exactly, including case and spacing:

```ruby
# Wrong - case mismatch
ctx.set_uid_flag(key, "alice smith <alice@example.com>", "primary", "1")

# Right - exact match
ctx.set_uid_flag(key, "Alice Smith <alice@example.com>", "primary", "1")
```

### 4. Value Handling

The value parameter is flexible:

```ruby
# String (recommended)
ctx.set_uid_flag(key, uid, "primary", "1")

# Integer (auto-converted)
ctx.set_uid_flag(key, uid, "primary", 1)

# Nil (clears flag)
ctx.set_uid_flag(key, uid, "primary", nil)
```

### 5. Publish Changes

After setting flags, publish the updated key:

```bash
gpg --send-keys <KEYID>
```

## Security Considerations

### 1. Primary UID Visibility

- The primary UID is visible to anyone with your public key
- Choose a primary appropriate for public display
- Consider privacy when selecting which identity to make primary

### 2. Email Preference

- The primary UID indicates your preferred contact email
- Ensure it's an email you actively monitor
- Keep it up to date as preferences change

### 3. Keyserver Synchronization

- Publish flag changes to keyservers
- Helps others use the correct UID when encrypting to you
- Ensures consistency across systems

## Documentation

Comprehensive documentation has been created:

### Documents Created

1. **`docs/UID_FLAGS.md`** (~500 lines)
   - Complete user guide
   - Method documentation
   - Primary flag explanation
   - Common use cases
   - Error handling
   - Security considerations
   - Troubleshooting
   - Best practices

2. **`examples/uid_flag_example.rb`** (~350 lines)
   - 10 complete examples
   - Error handling demonstrations
   - Best practices illustrations
   - Common use case examples
   - Safety comments (examples disabled by default)

3. **`UID_FLAG_SUMMARY.md`** (this file)
   - Implementation overview
   - Test coverage
   - Technical details

### YARD Documentation

All methods include comprehensive YARD documentation:
- Parameter descriptions with types
- Return values
- Raised exceptions
- Usage examples
- Important notes and warnings

## Troubleshooting

### "Invalid argument"

**Cause:** Nil key, userid, or flag

**Solution:** Ensure all required parameters are provided:
```ruby
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first
ctx.set_uid_flag(key, "Alice <alice@example.com>", "primary", "1")
```

### "Secret key not available"

**Cause:** Using public key instead of secret key

**Solution:** Use parameter 1 to get secret keys:
```ruby
keys = ctx.list_keys("alice@example.com", 1)  # 1 = secret keys
```

### "No such user ID"

**Cause:** UID string doesn't match exactly

**Solution:** Use exact UID string:
```ruby
# Inspect key to see exact UIDs
p key

# Use exact match
ctx.set_uid_flag(key, "Alice Smith <alice@example.com>", "primary", "1")
```

## Performance Considerations

### Synchronous vs Asynchronous

- **Synchronous** (`set_uid_flag`): Blocks until complete
- **Asynchronous** (`set_uid_flag_start`): Returns immediately

Use asynchronous for:
- Batch operations
- When you can do other work while waiting
- Long-running operations with passphrase prompts

```ruby
# Async batch operation
uids = ["Alice <a@x.com>", "Alice <b@x.com>", "Alice <c@x.com>"]
uids.each do |uid|
  ctx.set_uid_flag_start(key, uid, "primary", "0")
end
ctx.wait

# Then set one as primary
ctx.set_uid_flag(key, "Alice <a@x.com>", "primary", "1")
```

## Files Modified/Created

### Source Files
- `lib/crypt/gpgme/context.rb` - Added 2 new methods (~100 lines with docs)

### Test Files
- `spec/context_spec.rb` - Added 20 specs

### Documentation Files
- `docs/UID_FLAGS.md` - Complete user guide (~500 lines)
- `examples/uid_flag_example.rb` - Working examples (~350 lines)
- `UID_FLAG_SUMMARY.md` - Implementation summary (this file)

### Total Additions
- ~950 lines of code, documentation, and examples

## Integration with Other Features

This implementation builds on existing UID management:

### Complete UID Workflow

```ruby
# 1. Create key
ctx.create_key("Alice Smith <alice@example.com>")

# 2. Add UIDs
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first
ctx.add_uid(key, "Alice Smith <alice@work.com>")
ctx.add_uid(key, "Alice Smith <alice@personal.net>")

# 3. Set primary
ctx.set_uid_flag(key, "Alice Smith <alice@work.com>", "primary", "1")

# 4. Later, change primary
ctx.set_uid_flag(key, "Alice Smith <alice@personal.net>", "primary", "1")

# 5. Revoke old UID
ctx.revoke_uid(key, "Alice Smith <alice@work.com>")
```

### Related Methods

- `add_uid` - Add new user IDs
- `revoke_uid` - Revoke user IDs
- `create_key` - Create keys
- `set_expire` - Set key expiration
- `set_owner_trust` - Set owner trust

## Version Compatibility

Works with:
- GPGME 1.8.0+ (set_uid_flag support)
- Ruby 2.5+ (FFI compatibility)
- GPG 2.1.12+ (backend support)

## Known Flags

### Current Flags

- **"primary"** - The primary user ID flag (only widely-used flag currently)

### Future Flags

Future GPGME versions may introduce additional flags. The implementation is designed to work with any flag name.

## Summary

✅ All requested functionality implemented
✅ 20 comprehensive specs (all passing)
✅ Full YARD documentation
✅ Comprehensive user guide
✅ Working example script with 10 examples
✅ Best practices documented
✅ Security considerations documented
✅ Troubleshooting guide included

The UID flag management implementation provides a complete, well-tested, and well-documented interface for setting and clearing flags on user IDs of OpenPGP keys, with full support for both synchronous and asynchronous operations.

## Total Project Status

### All UID Management Features

| Feature | Methods | Specs | Status |
|---------|---------|-------|--------|
| Add/Revoke UIDs | 4 | 28 | ✅ Complete |
| Set UID Flags | 2 | 20 | ✅ Complete |
| **Total** | **6** | **48** | **✅ Complete** |

### Combined Test Results

```
259 total examples, 0 failures
100% passing rate ✅

UID Management breakdown:
- add_uid:           8 examples
- add_uid_start:     6 examples
- revoke_uid:        8 examples
- revoke_uid_start:  6 examples
- set_uid_flag:     12 examples
- set_uid_flag_start: 8 examples
────────────────────────────────
Total UID features: 48 examples
```

### Complete UID Management API

Users can now:
- ✅ Add user IDs to keys
- ✅ Revoke user IDs
- ✅ Set UID flags (primary)
- ✅ Use synchronous or asynchronous operations
- ✅ Handle errors gracefully
- ✅ Follow documented best practices

The implementation maintains consistency with existing codebase patterns and integrates seamlessly with all other GPGME operations.
