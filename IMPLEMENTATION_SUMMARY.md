# Key Expiration Support - Implementation Summary

## Overview
Added support for setting expiration times on keys and subkeys using GPGME's `gpgme_op_setexpire` functions.

## Changes Made

### 1. FFI Function Bindings (`lib/crypt/gpgme/functions.rb`)
Added two new FFI function bindings:
- `gpgme_op_setexpire` - Synchronous version
- `gpgme_op_setexpire_start` - Asynchronous version

### 2. Context Methods (`lib/crypt/gpgme/context.rb`)
Added two new public methods to the `Crypt::GPGME::Context` class:

#### `set_expire(key, expires, subfprs = nil, reserved = 0)`
Synchronous method to set key expiration time.

**Parameters:**
- `key`: The key to modify (Crypt::GPGME::Key or Structs::Key)
- `expires`: Expiration time in seconds from now, or 0 for no expiration
- `subfprs`: Optional newline-separated fingerprints of subkeys
- `reserved`: Reserved parameter (must be 0)

**Returns:** `nil`

**Raises:** `Crypt::GPGME::Error` if operation fails

#### `set_expire_start(key, expires, subfprs = nil, reserved = 0)`
Asynchronous version of `set_expire`. Returns immediately and requires calling `wait()` to complete.

### 3. Test Coverage (`spec/context_spec.rb`)
Added 17 comprehensive specs:
- 8 specs for `set_expire`
- 9 specs for `set_expire_start`

Tests cover:
- Basic functionality verification
- Method signature validation
- Error handling (nil key, invalid parameters)
- Parameter acceptance (expires, subfprs, reserved)
- Synchronous/asynchronous consistency

### 4. Documentation
Created comprehensive documentation:
- **Example script**: `examples/set_expire_example.rb`
  - Demonstrates usage with real keys
  - Shows how to calculate expiration periods
  - Includes safety comments for actual modifications

- **User guide**: `docs/SET_EXPIRE.md`
  - Complete API reference
  - Usage examples for common scenarios
  - Common time period constants
  - Error handling examples
  - Notes about authentication and permissions

### 5. YARD Documentation
Added extensive YARD documentation to both methods including:
- Parameter descriptions with types
- Return values
- Raised exceptions
- Multiple usage examples
- Important notes about authentication and time calculation

## Test Results
All 155 specs pass successfully:
- 138 existing specs (unchanged)
- 17 new specs for set_expire functionality

```
Finished in 1.32 seconds
155 examples, 0 failures
```

## Usage Examples

### Set primary key to expire in 1 year
```ruby
ctx = Crypt::GPGME::Context.new
key = ctx.list_keys("user@example.com").first
ctx.set_expire(key, 365 * 24 * 60 * 60)
```

### Set primary key to never expire
```ruby
ctx.set_expire(key, 0)
```

### Set specific subkeys to expire
```ruby
subfprs = "FPR1\nFPR2"
ctx.set_expire(key, 180 * 24 * 60 * 60, subfprs)
```

### Asynchronous operation
```ruby
ctx.set_expire_start(key, 365 * 24 * 60 * 60)
ctx.wait
```

## Important Notes

1. **Authentication Required**: Operations require the key's passphrase (prompted via pinentry or callback)

2. **Relative Time**: The `expires` parameter is relative to the current time, not an absolute timestamp

3. **Permission Required**: Users must have permission to modify the key (typically their own keys)

4. **Primary vs Subkeys**:
   - `subfprs = nil` → modifies primary key only
   - `subfprs = "FPR1\nFPR2"` → modifies specified subkeys

## API Consistency
The implementation follows existing patterns in the codebase:
- Synchronous/asynchronous method pairs (like `list_keys`/`list_keys_start`)
- Error handling via `Crypt::GPGME::Error`
- Key parameter accepts both wrapper and struct types
- Comprehensive YARD documentation
- Extensive spec coverage

## Files Modified/Created
- Modified: `lib/crypt/gpgme/functions.rb` (added 2 FFI bindings)
- Modified: `lib/crypt/gpgme/context.rb` (added 2 methods + ~75 lines of docs)
- Modified: `spec/context_spec.rb` (added 17 specs)
- Created: `examples/set_expire_example.rb` (70 lines)
- Created: `docs/SET_EXPIRE.md` (comprehensive user guide)
- Created: `IMPLEMENTATION_SUMMARY.md` (this file)

## Backwards Compatibility
No breaking changes. All existing functionality preserved. This is a pure addition to the API.
