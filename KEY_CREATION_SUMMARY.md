# Key Creation Implementation Summary

## Overview

This document summarizes the implementation of key and subkey creation functionality in the crypt-gpgme library.

## Implemented Methods

### 1. `Context#create_key(userid, algo, reserved, expires, certkey, flags)`

Creates a new primary OpenPGP key pair.

**Parameters:**
- `userid` (String, required): User ID for the key (e.g., "Name <email@example.com>")
- `algo` (String, optional): Algorithm specification (default: "future-default")
- `reserved` (Integer, optional): Reserved for future use (default: 0)
- `expires` (Integer, optional): Expiration time in seconds from now (default: 0 for no expiration)
- `certkey` (Key, optional): Certification key for signing the new key
- `flags` (Integer, optional): Bitwise OR of GPGME_CREATE_* flags (default: 0)

**Returns:** Hash with `:fpr` key containing the fingerprint of the created primary key

**Example:**
```ruby
result = ctx.create_key(
  "John Doe <john@example.com>",
  "future-default",
  0,
  31536000,  # 1 year
  nil,
  Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_ENCR
)
puts "Created key: #{result[:fpr]}"
```

### 2. `Context#create_key_start(userid, algo, reserved, expires, certkey, flags)`

Asynchronous version of `create_key`. Initiates the operation without waiting for completion.

**Usage:**
```ruby
ctx.create_key_start("John Doe <john@example.com>")
# ... do other work ...
ctx.wait
result = ctx.get_genkey_result
```

### 3. `Context#create_subkey(key, algo, reserved, expires, flags)`

Creates a new subkey for an existing key.

**Parameters:**
- `key` (Key, required): The key to add a subkey to
- `algo` (String, optional): Algorithm specification (default: "future-default")
- `reserved` (Integer, optional): Reserved for future use (default: 0)
- `expires` (Integer, optional): Expiration time in seconds from now (default: 0)
- `flags` (Integer, optional): Bitwise OR of GPGME_CREATE_* flags (default: 0)

**Returns:** Hash with `:fpr` key containing the fingerprint of the created subkey

**Example:**
```ruby
keys = ctx.keys("john@example.com")
key = keys.first

result = ctx.create_subkey(
  key,
  "future-default",
  0,
  0,  # No expiration
  Crypt::GPGME::GPGME_CREATE_ENCR
)
puts "Created subkey: #{result[:fpr]}"
```

### 4. `Context#create_subkey_start(key, algo, reserved, expires, flags)`

Asynchronous version of `create_subkey`.

### 5. `Context#get_genkey_result()`

Retrieves the result of the most recent key generation operation.

**Returns:** Hash with `:fpr` key, or empty hash if no operation was performed

**Example:**
```ruby
ctx.create_key_start("John Doe <john@example.com>")
ctx.wait
result = ctx.get_genkey_result
puts "Generated key: #{result[:fpr]}"
```

## Algorithm Specifications

The `algo` parameter accepts strings describing the algorithm and key size:

### Recommended Algorithms

- **`"future-default"`** (Recommended): Let GPGME choose the best algorithm
- **`"ed25519/cv25519"`**: Modern elliptic curve (EdDSA signing, ECDH encryption)
- **`"ed448/cv448"`**: Larger elliptic curve variant
- **`"rsa4096"`**: 4096-bit RSA (traditional, widely compatible)

### Legacy Algorithms

- `"rsa2048"`: 2048-bit RSA (minimum recommended size)
- `"rsa3072"`: 3072-bit RSA
- `"nistp256"`, `"nistp384"`, `"nistp521"`: NIST curves
- `"brainpoolP256r1"`, `"brainpoolP384r1"`, `"brainpoolP512r1"`: Brainpool curves
- `"secp256k1"`: Bitcoin curve

## Creation Flags

Flags control the capabilities of the generated key:

### Key Capabilities

- `GPGME_CREATE_SIGN (1)`: Key can create signatures
- `GPGME_CREATE_ENCR (2)`: Key can encrypt data
- `GPGME_CREATE_CERT (4)`: Key can certify other keys
- `GPGME_CREATE_AUTH (8)`: Key can authenticate

### Key Policies

- `GPGME_CREATE_NOPASSWD (128)`: Create key without passphrase protection
- `GPGME_CREATE_SELFSIGN (256)`: Self-sign the key (default behavior)
- `GPGME_CREATE_NOSTORE (512)`: Don't store key in keyring
- `GPGME_CREATE_WANTPUB (1024)`: Want public key in result
- `GPGME_CREATE_WANTSEC (2048)`: Want secret key in result
- `GPGME_CREATE_FORCE (4096)`: Force key creation even if one exists
- `GPGME_CREATE_NOEXPIRE (8192)`: Key should not expire

### Combining Flags

Use bitwise OR to combine flags:

```ruby
# Primary key with signing and certification
flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT

# Encryption subkey
flags = Crypt::GPGME::GPGME_CREATE_ENCR

# Authentication subkey without passphrase
flags = Crypt::GPGME::GPGME_CREATE_AUTH | Crypt::GPGME::GPGME_CREATE_NOPASSWD
```

## Common Use Cases

### 1. Modern Key Pair (Primary + Encryption Subkey)

```ruby
# Create primary key for signing and certification
result = ctx.create_key(
  "John Doe <john@example.com>",
  "future-default",
  0,
  31536000,  # 1 year expiration
  nil,
  Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT
)

# Refresh key list
keys = ctx.keys("john@example.com")
key = keys.first

# Add encryption subkey
ctx.create_subkey(
  key,
  "future-default",
  0,
  31536000,
  Crypt::GPGME::GPGME_CREATE_ENCR
)
```

### 2. Ed25519 Key with Authentication

```ruby
# Primary key
result = ctx.create_key(
  "Admin <admin@example.com>",
  "ed25519/cv25519",
  0,
  0,  # No expiration
  nil,
  Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT
)

keys = ctx.keys("admin@example.com")
key = keys.first

# SSH authentication subkey
ctx.create_subkey(
  key,
  "ed25519",
  0,
  0,
  Crypt::GPGME::GPGME_CREATE_AUTH
)

# Encryption subkey
ctx.create_subkey(
  key,
  "cv25519",
  0,
  0,
  Crypt::GPGME::GPGME_CREATE_ENCR
)
```

### 3. Traditional RSA Key Pair

```ruby
# Create traditional RSA key with both capabilities
result = ctx.create_key(
  "Legacy User <legacy@example.com>",
  "rsa4096",
  0,
  0,
  nil,
  Crypt::GPGME::GPGME_CREATE_SIGN |
  Crypt::GPGME::GPGME_CREATE_ENCR |
  Crypt::GPGME::GPGME_CREATE_CERT
)
```

## Testing

### Test Coverage

The implementation includes 32 comprehensive specs covering:

#### `create_key` (9 specs)
- ✅ Basic functionality
- ✅ Parameter requirements (userid required)
- ✅ Optional parameters (algo, reserved, expires, certkey, flags)
- ✅ Method arity verification
- ✅ Return value validation (hash structure)

#### `create_key_start` (4 specs)
- ✅ Basic asynchronous functionality
- ✅ Parameter requirements
- ✅ Method signature consistency
- ✅ Async behavior verification

#### `create_subkey` (9 specs)
- ✅ Basic functionality
- ✅ Parameter requirements (key required)
- ✅ Optional parameters (algo, reserved, expires, flags)
- ✅ Method arity verification
- ✅ Error handling (nil key)

#### `create_subkey_start` (6 specs)
- ✅ Basic asynchronous functionality
- ✅ Parameter requirements
- ✅ Method signature consistency
- ✅ Async behavior verification
- ✅ Error handling (nil key)

#### `get_genkey_result` (4 specs)
- ✅ Basic functionality
- ✅ No parameters required
- ✅ Return value validation
- ✅ Empty result handling

### Running Tests

```bash
# Run all key creation specs
bundle exec rspec --format documentation --example "create"

# Run all specs
bundle exec rspec
```

### Current Test Results

```
28 examples for create_key/create_subkey
4 examples for get_genkey_result
─────────────────────────────
32 examples, 0 failures

Total suite: 211 examples, 0 failures
```

## Implementation Details

### FFI Bindings

The following GPGME functions are used (bindings already existed):

```ruby
attach_function :gpgme_op_createkey,
  [Structs::Context, :string, :string, :uint, :uint, Structs::Key, :uint],
  :uint

attach_function :gpgme_op_createkey_start,
  [Structs::Context, :string, :string, :uint, :uint, Structs::Key, :uint],
  :uint

attach_function :gpgme_op_createsubkey,
  [Structs::Context, Structs::Key, :string, :uint, :uint, :uint],
  :uint

attach_function :gpgme_op_createsubkey_start,
  [Structs::Context, Structs::Key, :string, :uint, :uint, :uint],
  :uint

attach_function :gpgme_op_genkey_result,
  [Structs::Context],
  Structs::GenkeyResult
```

### Error Handling

All methods raise `Crypt::GPGME::Error` on failure:

```ruby
raise Crypt::GPGME::Error.new(err) if err != 0
```

Common errors:
- Invalid algorithm specification
- Invalid user ID format
- Permission denied (keyring access)
- Invalid key parameter (nil or invalid)

### Result Structure

The result hash contains:
- `:fpr` - Fingerprint of the created key/subkey (String)

```ruby
result = ctx.create_key("John Doe <john@example.com>")
# => { fpr: "1234567890ABCDEF..." }
```

## Best Practices

### 1. Modern Cryptography

Prefer elliptic curve algorithms:
- Use `"future-default"` or `"ed25519/cv25519"`
- Avoid RSA unless compatibility required
- If RSA needed, use at least 4096 bits

### 2. Key Separation

Follow the principle of capability separation:
- Primary key: signing + certification only
- Separate subkeys for: encryption, authentication
- Easier to revoke/rotate specific capabilities

### 3. Expiration

Always set reasonable expiration times:
- Primary key: 2-5 years
- Subkeys: 1-2 years
- Can always extend before expiration

### 4. Passphrase Protection

Avoid `GPGME_CREATE_NOPASSWD` except for:
- Automated systems
- Ephemeral keys
- Testing environments

### 5. Testing

Before creating keys:
```ruby
# Test in offline mode first
ctx.armor = true
ctx.offline = true
```

## Documentation

See also:
- `docs/CREATE_KEY.md` - Detailed usage guide
- `examples/create_key_example.rb` - Working examples
- GPGME documentation: https://www.gnupg.org/documentation/manuals/gpgme/

## Troubleshooting

### "Invalid algorithm"
- Check algorithm string format
- Verify GPGME version supports the algorithm
- Try "future-default" for best compatibility

### "Invalid user ID"
- Must include email in angle brackets: "Name <email@example.com>"
- Check for special characters
- Verify encoding (UTF-8)

### "Permission denied"
- Check GPG agent is running
- Verify keyring permissions
- Check home directory settings

### "Key already exists"
- Use `GPGME_CREATE_FORCE` flag
- Delete existing key first
- Use different user ID

## Files Modified

- `lib/crypt/gpgme/context.rb` - Added 5 new methods (~200 lines with docs)
- `spec/context_spec.rb` - Added 32 specs
- Total additions: ~300 lines of code and documentation

## Summary

✅ All requested functionality implemented
✅ 32 comprehensive specs (all passing)
✅ Full YARD documentation
✅ Working example script
✅ Detailed usage guide
✅ Best practices documented

The key creation implementation provides a complete, well-tested interface for generating OpenPGP keys and subkeys with full control over algorithms, capabilities, and expiration times.
