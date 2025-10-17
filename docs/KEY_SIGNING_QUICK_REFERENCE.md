# Key Signing Quick Reference

## Methods Overview

### Key Signing
```ruby
# Synchronous
ctx.sign_key(key, userid = nil, expires = 0, flags = 0)

# Asynchronous
ctx.sign_key_start(key, userid = nil, expires = 0, flags = 0)
ctx.wait
```

### Signature Revocation
```ruby
# Synchronous
ctx.revoke_signature(key, signing_key = nil, userid = nil, flags = 0)

# Asynchronous
ctx.revoke_signature_start(key, signing_key = nil, userid = nil, flags = 0)
ctx.wait
```

## Common Use Cases

### 1. Sign All User IDs
```ruby
signing_key = ctx.list_keys("you@example.com", 1).first
ctx.add_signer(signing_key)

key_to_sign = ctx.list_keys("them@example.com").first
ctx.sign_key(key_to_sign)
```

### 2. Sign Specific User ID
```ruby
ctx.sign_key(key_to_sign, "Bob Smith <bob@work.com>")
```

### 3. Local Signature (Not Exportable)
```ruby
ctx.sign_key(key_to_sign, nil, 0, Crypt::GPGME::GPGME_KEYSIGN_LOCAL)
```

### 4. Expiring Signature (1 Year)
```ruby
expires = Time.now.to_i + (365 * 24 * 60 * 60)
ctx.sign_key(key_to_sign, nil, expires)
```

### 5. Non-Expiring Signature
```ruby
ctx.sign_key(key_to_sign, nil, 0, Crypt::GPGME::GPGME_KEYSIGN_NOEXPIRE)
```

### 6. Revoke Signature on All UIDs
```ruby
ctx.revoke_signature(signed_key, signing_key)
```

### 7. Revoke Signature on Specific UID
```ruby
ctx.revoke_signature(signed_key, signing_key, "Bob <bob@work.com>")
```

### 8. Revoke Using Current Signer
```ruby
ctx.add_signer(signing_key)
ctx.revoke_signature(signed_key, nil)
```

## Signing Flags

| Flag | Value | Description |
|------|-------|-------------|
| `GPGME_KEYSIGN_LOCAL` | 128 | Local signature (not exportable) |
| `GPGME_KEYSIGN_LFSEP` | 256 | Use linefeed as separator |
| `GPGME_KEYSIGN_NOEXPIRE` | 512 | Signature never expires |
| `GPGME_KEYSIGN_FORCE` | 1024 | Force signature creation |

### Combining Flags
```ruby
flags = Crypt::GPGME::GPGME_KEYSIGN_LOCAL | Crypt::GPGME::GPGME_KEYSIGN_NOEXPIRE
ctx.sign_key(key_to_sign, nil, 0, flags)
```

## Parameters Explained

### `sign_key` Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | Key/Structs::Key | ✅ Yes | The key to sign |
| `userid` | String/nil | ❌ No | Specific user ID (nil = all UIDs) |
| `expires` | Integer | ❌ No | Expiration (0 = none, Unix timestamp) |
| `flags` | Integer | ❌ No | Signing flags (default: 0) |

### `revoke_signature` Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | Key/Structs::Key | ✅ Yes | Key with signature to revoke |
| `signing_key` | Key/Structs::Key/nil | ❌ No | Key that made signature (nil = current) |
| `userid` | String/nil | ❌ No | Specific user ID (nil = all) |
| `flags` | Integer | ❌ No | Reserved (use 0) |

## Return Values

| Method | Returns |
|--------|---------|
| `sign_key` | `nil` |
| `sign_key_start` | `nil` |
| `revoke_signature` | `nil` |
| `revoke_signature_start` | `nil` |

All methods raise `Crypt::GPGME::Error` on failure.

## Requirements Checklist

### For Key Signing
- [ ] Have a secret key with signing capability
- [ ] Access to signing key's passphrase (via agent or callback)
- [ ] Have verified the identity of the key owner
- [ ] Target key exists in keyring

### For Signature Revocation
- [ ] Have the private key that made the signature
- [ ] Access to signing key's passphrase
- [ ] Signature exists on the target key
- [ ] Know which user ID has the signature (if revoking specific)

## Error Handling

```ruby
begin
  ctx.sign_key(key_to_sign)
  puts "Key signed successfully!"
rescue Crypt::GPGME::Error => e
  puts "Failed to sign key: #{e.message}"
  # Handle error (missing passphrase, wrong key, etc.)
end
```

## Common Errors

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "key cannot be nil" | No key provided | Pass a valid Key object |
| "gpgme_op_keysign failed" | GPGME operation failed | Check passphrase, key validity |
| "No secret key" | No signing key set | Call `add_signer()` first |
| "Bad passphrase" | Wrong passphrase | Verify passphrase or fix agent |

## Best Practices

1. **Always Verify**: Verify key owner's identity before signing
2. **Use Appropriate Flags**: Match flags to your trust level
3. **Document Policy**: Have a clear key signing policy
4. **Test Locally First**: Use local signatures for testing
5. **Keep Records**: Maintain records of verifications
6. **Revoke When Needed**: Don't hesitate to revoke if circumstances change
7. **Publish Changes**: Publish signed keys and revocations to key servers

## Integration with Other Methods

### Complete Workflow
```ruby
# 1. Setup context and get signing key
ctx = Crypt::GPGME::Context.new
my_key = ctx.list_keys("me@example.com", 1).first
ctx.add_signer(my_key)

# 2. Find and verify the key to sign
their_key = ctx.list_keys("them@example.com").first
puts "Fingerprint: #{their_key.subkeys.first.fpr}"
# VERIFY THIS FINGERPRINT IN PERSON!

# 3. Sign the key
ctx.sign_key(their_key)

# 4. Export the signed key
export_data = Crypt::GPGME::Data.new
ctx.export(their_key.subkeys.first.fpr, export_data)
signed_key = export_data.read

# 5. Send or publish the signed key
File.write("signed_key.asc", signed_key)

# 6. Later, if needed, revoke the signature
# ctx.revoke_signature(their_key, my_key)
```

## Async Operations

For long-running operations or non-blocking code:

```ruby
# Start async operation
ctx.sign_key_start(key_to_sign)

# Do other work here...

# Wait for completion
ctx.wait

# Continue with result
puts "Signing complete!"
```

## Testing

The library includes comprehensive unit tests:

```ruby
# Run all tests
bundle exec rspec

# Run only signing tests
bundle exec rspec spec/context_spec.rb -e "sign_key"

# Run only revocation tests
bundle exec rspec spec/context_spec.rb -e "revoke_signature"
```

## See Also

- `add_signer()` - Add signing key to context
- `add_uid()` - Add user ID to your own key
- `revoke_uid()` - Revoke user ID from your own key
- `export()` - Export signed keys
- `import()` - Import keys with signatures

## Documentation

Full YARD documentation is available:

```ruby
# Generate docs
yard doc

# View in browser
yard server
```

Or view inline:
```ruby
ri Crypt::GPGME::Context#sign_key
ri Crypt::GPGME::Context#revoke_signature
```
