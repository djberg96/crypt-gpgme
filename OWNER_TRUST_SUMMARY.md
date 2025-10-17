# Owner Trust Support - Implementation Summary

## Overview
Added support for setting owner trust levels on OpenPGP keys using GPGME's `gpgme_op_setownertrust` functions.

## Changes Made

### 1. FFI Function Bindings (`lib/crypt/gpgme/functions.rb`)
Added two new FFI function bindings:
- `gpgme_op_setownertrust` - Synchronous version
- `gpgme_op_setownertrust_start` - Asynchronous version

### 2. Context Methods (`lib/crypt/gpgme/context.rb`)
Added two new public methods to the `Crypt::GPGME::Context` class:

#### `set_owner_trust(key, value)`
Synchronous method to set owner trust level.

**Parameters:**
- `key`: The key to modify (Crypt::GPGME::Key or Structs::Key)
- `value`: Trust value as String or Integer
  - Strings: "unknown", "undefined", "never", "marginal", "full", "ultimate"
  - Integers: 0-5 (corresponding to GPGME_VALIDITY_* constants)

**Features:**
- Accepts both string and integer trust values
- Case-insensitive string matching
- Automatic conversion to GPGME's expected format
- Validates trust values (0-5 for integers)
- Type checking with helpful error messages

**Returns:** `nil`

**Raises:**
- `ArgumentError` for invalid values or types
- `Crypt::GPGME::Error` if operation fails

#### `set_owner_trust_start(key, value)`
Asynchronous version of `set_owner_trust`. Returns immediately and requires calling `wait()` to complete.

### 3. Test Coverage (`spec/context_spec.rb`)
Added 24 comprehensive specs:
- 14 specs for `set_owner_trust`
- 10 specs for `set_owner_trust_start`

Tests cover:
- Basic functionality verification
- Method signature validation
- Error handling (nil key, invalid values, invalid types)
- String value acceptance (all trust levels)
- Integer value acceptance (0-5)
- Case-insensitive string handling
- ArgumentError for invalid trust values
- ArgumentError for invalid types
- Synchronous/asynchronous consistency

### 4. Documentation
Created comprehensive documentation:

- **Example script**: `examples/set_owner_trust_example.rb`
  - Explains Web of Trust concepts
  - Shows all trust levels with descriptions
  - Demonstrates both string and integer usage
  - Includes important security notes
  - Safety comments for actual modifications

- **User guide**: `docs/SET_OWNER_TRUST.md`
  - Complete API reference
  - Web of Trust explanation
  - Trust level descriptions
  - Usage examples for common scenarios
  - Trust calculation implications
  - Important notes about security
  - Common patterns and best practices
  - Constants reference

### 5. YARD Documentation
Added extensive YARD documentation to both methods including:
- Parameter descriptions with types and accepted values
- Return values
- Raised exceptions
- Multiple usage examples
- Important notes about OpenPGP, Web of Trust, and security
- Cross-references to related functionality

## Test Results
All 179 specs pass successfully:
- 155 existing specs (unchanged)
- 24 new specs for set_owner_trust functionality

```
Finished in 1.3 seconds
179 examples, 0 failures
```

## Usage Examples

### Set trust using strings
```ruby
ctx = Crypt::GPGME::Context.new
key = ctx.list_keys("user@example.com").first

ctx.set_owner_trust(key, "full")      # Full trust
ctx.set_owner_trust(key, "ultimate")  # Ultimate trust
ctx.set_owner_trust(key, "marginal")  # Marginal trust
ctx.set_owner_trust(key, "never")     # Never trust
```

### Set trust using integers
```ruby
ctx.set_owner_trust(key, 4)  # Full trust
ctx.set_owner_trust(key, 5)  # Ultimate trust
ctx.set_owner_trust(key, 3)  # Marginal trust

# Or use constants
ctx.set_owner_trust(key, Crypt::GPGME::GPGME_VALIDITY_FULL)
```

### Case-insensitive strings
```ruby
ctx.set_owner_trust(key, "FULL")  # Works (converted to lowercase)
```

### Asynchronous operation
```ruby
ctx.set_owner_trust_start(key, "full")
ctx.wait
```

## Important Concepts

### Owner Trust vs Key Validity

**Owner Trust** (what we set):
- YOUR personal assessment of the key owner's trustworthiness as a certifier
- Stored locally in your trustdb
- Not shared with others
- Affects Web of Trust calculations

**Key Validity** (automatically calculated):
- Determined by GPGME based on signatures and trust paths
- Based on owner trust of signing keys
- Indicates confidence in key-to-identity binding

### Trust Levels Explained

| Level | Value | When to Use |
|-------|-------|-------------|
| Ultimate | 5 | Only for YOUR OWN keys (keys you control) |
| Full | 4 | For people you trust as much as yourself to verify others |
| Marginal | 3 | For people you somewhat trust to verify others |
| Never | 2 | For keys you don't trust to certify others |
| Undefined | 1 | Default state when not yet decided |
| Unknown | 0 | System hasn't determined trust |

### Web of Trust Impact

- **Ultimate trust**: All keys signed by this key are considered fully valid
- **Full trust**: One fully-trusted signature can validate a key
- **Marginal trust**: Multiple marginally-trusted signatures needed (typically 3)
- **Never trust**: Signatures from this key are ignored

## Value Conversion Logic

The implementation includes smart value conversion:

```ruby
# String to internal format
"full" → "full"
"FULL" → "full" (case-insensitive)

# Integer to internal format
4 → "full"
5 → "ultimate"
GPGME_VALIDITY_FULL → "full"

# Validation
99 → ArgumentError (invalid value)
[] → ArgumentError (invalid type)
```

## API Consistency
The implementation follows existing patterns in the codebase:
- Synchronous/asynchronous method pairs (like `set_expire`)
- Error handling via `Crypt::GPGME::Error` and `ArgumentError`
- Key parameter accepts both wrapper and struct types
- Comprehensive YARD documentation
- Extensive spec coverage
- Flexible parameter handling (strings and integers)

## Security Notes

### Critical Guidelines

1. **Ultimate trust**: ONLY for your own keys
2. **Full trust**: Use sparingly - implies complete trust in their judgement
3. **Local setting**: Owner trust is not shared, it's your personal assessment
4. **OpenPGP only**: This feature is specific to OpenPGP/GPG keys
5. **Web of Trust**: Your trust settings affect validity of all keys in the chain

## Files Modified/Created

- Modified: `lib/crypt/gpgme/functions.rb` (added 2 FFI bindings)
- Modified: `lib/crypt/gpgme/context.rb` (added 2 methods + ~120 lines including docs)
- Modified: `spec/context_spec.rb` (added 24 specs)
- Created: `examples/set_owner_trust_example.rb` (90+ lines)
- Created: `docs/SET_OWNER_TRUST.md` (comprehensive user guide, 300+ lines)
- Created: `OWNER_TRUST_SUMMARY.md` (this file)

## Backwards Compatibility
No breaking changes. All existing functionality preserved. This is a pure addition to the API.

## Related Functionality
Complements existing features:
- `key.owner_trust` - Read current owner trust level
- `set_expire` - Set key expiration times
- `list_keys` - Find keys to modify
- Web of Trust calculations use owner trust automatically

## Future Enhancements
Potential additions could include:
- Batch trust setting for multiple keys
- Trust management helpers (e.g., `trust_all_own_keys`)
- Trust level recommendation based on signatures
- Trust database export/import
