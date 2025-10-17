# Creating Keys and Subkeys

The `create_key`, `create_subkey`, and related methods allow you to generate new OpenPGP keys and subkeys programmatically.

## Overview

- **Primary Key Creation**:
  - Synchronous: `create_key(userid, algo = nil, reserved = 0, expires = 0, certkey = nil, flags = 0)`
  - Asynchronous: `create_key_start(userid, algo = nil, reserved = 0, expires = 0, certkey = nil, flags = 0)`

- **Subkey Creation**:
  - Synchronous: `create_subkey(key, algo = nil, reserved = 0, expires = 0, flags = 0)`
  - Asynchronous: `create_subkey_start(key, algo = nil, reserved = 0, expires = 0, flags = 0)`

- **Result Retrieval**: `get_genkey_result()`

## Parameters

### create_key
- `userid`: User ID string (e.g., "Name <email@example.com>")
- `algo`: Algorithm specification (default: "future-default")
- `reserved`: Reserved parameter, must be 0
- `expires`: Expiration time in seconds from now, or 0 for no expiration
- `certkey`: Optional certification key (for subkey creation)
- `flags`: Creation flags (bitwise OR of GPGME_CREATE_* constants)

### create_subkey
- `key`: Primary key to add subkey to
- `algo`: Algorithm specification (default: "future-default")
- `reserved`: Reserved parameter, must be 0
- `expires`: Expiration time in seconds from now, or 0 for no expiration
- `flags`: Creation flags (bitwise OR of GPGME_CREATE_* constants)

## Algorithms

### Common Algorithms

| Algorithm | Type | Use Case | Speed | Compatibility |
|-----------|------|----------|-------|---------------|
| `rsa2048` | RSA | General purpose | Slow | Universal |
| `rsa3072` | RSA | Higher security | Slower | Universal |
| `rsa4096` | RSA | Maximum security | Slowest | Universal |
| `ed25519` | EdDSA | Signing | Very fast | Modern |
| `cv25519` | ECDH | Encryption | Very fast | Modern |
| `future-default` | Auto | Let GPGME choose | Varies | Current best |

### Algorithm Notes
- **RSA**: Traditional, widely compatible, but slow for key generation
- **Ed25519**: Modern signing algorithm, very fast, secure
- **Cv25519**: Modern encryption algorithm, pairs well with Ed25519
- **future-default**: GPGME selects the best current algorithm

## Creation Flags

Flags control key capabilities and behavior:

```ruby
GPGME_CREATE_SIGN       = (1 << 0)   # Allow signing
GPGME_CREATE_ENCR       = (1 << 1)   # Allow encryption
GPGME_CREATE_CERT       = (1 << 2)   # Allow certification
GPGME_CREATE_AUTH       = (1 << 3)   # Allow authentication
GPGME_CREATE_NOPASSWD   = (1 << 7)   # No passphrase
GPGME_CREATE_SELFSIGNED = (1 << 8)   # Self-signed cert
GPGME_CREATE_NOSTORE    = (1 << 9)   # Don't store in keyring
GPGME_CREATE_WANTPUB    = (1 << 10)  # Return public key
GPGME_CREATE_WANTSEC    = (1 << 11)  # Return secret key
GPGME_CREATE_FORCE      = (1 << 12)  # Force creation
GPGME_CREATE_NOEXPIRE   = (1 << 13)  # No expiration
GPGME_CREATE_ADSK       = (1 << 14)  # Add ADSK
```

### Combining Flags

```ruby
# Multiple capabilities
flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_ENCR

# Sign and certify (typical for primary key)
flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT

# Encryption only (typical for subkey)
flags = Crypt::GPGME::GPGME_CREATE_ENCR
```

## Basic Usage

### Create a Simple Key

```ruby
require 'crypt/gpgme'

ctx = Crypt::GPGME::Context.new

# Create basic RSA key
result = ctx.create_key("Alice <alice@example.com>", "rsa2048")
puts "Created key: #{result[:fpr]}"
```

### Create Modern Ed25519 Key

```ruby
# Ed25519 is faster and more secure than RSA
result = ctx.create_key("Bob <bob@example.com>", "ed25519")
puts "Created key: #{result[:fpr]}"

# Retrieve the key
key = ctx.list_keys("bob@example.com").first
puts "User ID: #{key.uids.first.uid}"
```

### Create Key with Specific Capabilities

```ruby
# Create key with signing and certification capabilities
flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT
result = ctx.create_key("Carol <carol@example.com>", "rsa2048", 0, 0, nil, flags)
```

### Create Key with Expiration

```ruby
# Create key that expires in 1 year
one_year = 365 * 24 * 60 * 60
result = ctx.create_key("Dave <dave@example.com>", "rsa2048", 0, one_year)

# Create key that never expires
flags = Crypt::GPGME::GPGME_CREATE_NOEXPIRE
result = ctx.create_key("Eve <eve@example.com>", "rsa2048", 0, 0, nil, flags)
```

## Creating Subkeys

### Add Encryption Subkey

```ruby
# Get existing key
key = ctx.list_keys("alice@example.com").first

# Create encryption subkey
flags = Crypt::GPGME::GPGME_CREATE_ENCR
result = ctx.create_subkey(key, "rsa2048", 0, 0, flags)
puts "Added subkey: #{result[:fpr]}"
```

### Add Signing Subkey

```ruby
# Add additional signing subkey
flags = Crypt::GPGME::GPGME_CREATE_SIGN
result = ctx.create_subkey(key, "ed25519", 0, 0, flags)
```

### Add Subkey with Expiration

```ruby
# Create subkey that expires in 6 months
six_months = 180 * 24 * 60 * 60
flags = Crypt::GPGME::GPGME_CREATE_ENCR
result = ctx.create_subkey(key, "cv25519", 0, six_months, flags)
```

## Best Practice: Modern Key Setup

### Recommended Configuration

```ruby
# 1. Create primary key for signing and certification (Ed25519)
flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT
result = ctx.create_key("Alice <alice@example.com>", "ed25519", 0, 0, nil, flags)
puts "Primary key: #{result[:fpr]}"

# 2. Retrieve the key
key = ctx.list_keys("alice@example.com").first

# 3. Add encryption subkey (Cv25519)
flags = Crypt::GPGME::GPGME_CREATE_ENCR
result = ctx.create_subkey(key, "cv25519", 0, 0, flags)
puts "Encryption subkey: #{result[:fpr]}"

# Now you have a modern key setup:
# - Fast signing with Ed25519
# - Fast encryption with Cv25519
# - Primary key can certify other keys
```

### Why This Configuration?

1. **Ed25519 for signing**: Fast, secure, compact signatures
2. **Cv25519 for encryption**: Fast, secure encryption
3. **Separate subkeys**: Can have different expirations, easier to rotate
4. **Primary key for certification**: Controls the Web of Trust

## Asynchronous Operations

### Async Key Creation

```ruby
# Start key creation
ctx.create_key_start("Bob <bob@example.com>", "ed25519")

# Do other work...

# Wait for completion
ctx.wait

# Get result
result = ctx.get_genkey_result
puts "Created key: #{result[:fpr]}"
```

### Async Subkey Creation

```ruby
key = ctx.list_keys("bob@example.com").first

flags = Crypt::GPGME::GPGME_CREATE_ENCR
ctx.create_subkey_start(key, "cv25519", 0, 0, flags)
ctx.wait

result = ctx.get_genkey_result
puts "Created subkey: #{result[:fpr]}"
```

## Advanced Usage

### Multiple Subkeys with Different Purposes

```ruby
key = ctx.list_keys("alice@example.com").first

# Encryption subkey (never expires)
flags = Crypt::GPGME::GPGME_CREATE_ENCR
ctx.create_subkey(key, "cv25519", 0, 0, flags)

# Signing subkey (expires in 1 year)
one_year = 365 * 24 * 60 * 60
flags = Crypt::GPGME::GPGME_CREATE_SIGN
ctx.create_subkey(key, "ed25519", 0, one_year, flags)

# Authentication subkey (for SSH)
flags = Crypt::GPGME::GPGME_CREATE_AUTH
ctx.create_subkey(key, "ed25519", 0, 0, flags)
```

### Create Key Without Passphrase

```ruby
# For automated testing or special purposes only
flags = Crypt::GPGME::GPGME_CREATE_NOPASSWD
result = ctx.create_key("Test <test@example.com>", "ed25519", 0, 0, nil, flags)
```

## Important Notes

### Authentication Requirements

- Key creation requires passphrase entry via pinentry
- Set `GPGME_CREATE_NOPASSWD` flag to skip passphrase (not recommended for production)
- Ensure pinentry is configured in your environment

### Performance Considerations

- **RSA key generation is slow**, especially for 4096-bit keys
- **Ed25519/Cv25519 are very fast** (seconds vs minutes)
- Key generation uses system entropy
- Consider asynchronous operations for UI responsiveness

### Key Management Best Practices

1. **Use modern algorithms**: Ed25519 + Cv25519
2. **Set expiration dates**: Easier to rotate, better security
3. **Separate subkeys by purpose**: Signing, encryption, authentication
4. **Keep primary key offline**: Use subkeys for daily operations
5. **Regular backups**: Secure backup of secret keys
6. **Strong passphrases**: Protect private keys properly

### Common Patterns

#### Daily Use Key

```ruby
# Primary key: signing + certification (Ed25519)
flags = Crypt::GPGME::GPGME_CREATE_SIGN | Crypt::GPGME::GPGME_CREATE_CERT
result = ctx.create_key("user@example.com", "ed25519", 0, 0, nil, flags)
key = ctx.list_keys("user@example.com").first

# Subkey: encryption (Cv25519)
flags = Crypt::GPGME::GPGME_CREATE_ENCR
ctx.create_subkey(key, "cv25519", 0, 0, flags)
```

#### SSH Authentication Key

```ruby
# Create key with authentication capability
flags = Crypt::GPGME::GPGME_CREATE_AUTH
result = ctx.create_key("ssh@example.com", "ed25519", 0, 0, nil, flags)
```

#### Temporary/Test Key

```ruby
# Short-lived test key
one_day = 24 * 60 * 60
flags = Crypt::GPGME::GPGME_CREATE_NOPASSWD  # For testing only
result = ctx.create_key("test@example.com", "ed25519", 0, one_day, nil, flags)
```

## Troubleshooting

### Passphrase Entry Issues

```ruby
# If pinentry fails, check:
# - GPG_TTY environment variable is set
# - pinentry-program in gpg-agent.conf is correct
# - gpg-agent is running

# Set GPG_TTY in your shell:
# export GPG_TTY=$(tty)
```

### Key Generation Hangs

```ruby
# RSA key generation requires entropy
# If it hangs:
# - Use modern algorithms (ed25519) instead
# - Generate entropy: move mouse, type, disk I/O
# - Check system entropy: cat /proc/sys/kernel/random/entropy_avail
```

### Invalid Algorithm Error

```ruby
# Check supported algorithms:
# gpg --version
# gpg --expert --full-gen-key  # Shows available options

# Stick to common algorithms:
# - rsa2048, rsa3072, rsa4096
# - ed25519
# - cv25519
```

## See Also

- [GPGME Manual - Key Management](https://www.gnupg.org/documentation/manuals/gpgme/)
- [GnuPG - Key Generation](https://www.gnupg.org/gph/en/manual/c14.html)
- `examples/create_key_example.rb` for complete working examples
- Related methods: `set_expire`, `set_owner_trust`, `list_keys`
