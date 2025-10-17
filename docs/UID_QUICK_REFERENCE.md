# User ID Management Quick Reference

## Basic Usage

```ruby
require 'crypt/gpgme'

ctx = Crypt::GPGME::Context.new

# Get your secret key
keys = ctx.list_keys("you@example.com", 1)  # 1 = secret keys
key = keys.first
```

## Adding User IDs

### Synchronous
```ruby
# Add a new email address
ctx.add_uid(key, "Your Name <new@example.com>")

# Add with comment
ctx.add_uid(key, "Your Name (Work) <work@example.com>")
```

### Asynchronous
```ruby
ctx.add_uid_start(key, "Your Name <new@example.com>")
ctx.wait
```

## Revoking User IDs

### Synchronous
```ruby
# Revoke an old email (must match exactly)
ctx.revoke_uid(key, "Your Name <old@example.com>")
```

### Asynchronous
```ruby
ctx.revoke_uid_start(key, "Your Name <old@example.com>")
ctx.wait
```

## User ID Format

### Valid Formats
✓ `"Alice Smith <alice@example.com>"`
✓ `"Bob Jones (Work) <bob@company.com>"`
✓ `"系統管理員 <admin@example.jp>"` (UTF-8)

### Invalid Formats
✗ `"alice@example.com"` (missing name and brackets)
✗ `"Alice"` (missing email)
✗ `"Alice alice@example.com"` (missing brackets)

## Requirements

- Must use a **secret key** (not public)
- Must have access to the **key's passphrase**
- UID must be in **valid format**
- For revocation: UID string must **match exactly**

## Error Handling

```ruby
begin
  ctx.add_uid(key, "Name <email@example.com>")
rescue Crypt::GPGME::Error => e
  puts "Error: #{e.message}"
end
```

## Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| "Invalid argument" | Nil key or nil userid | Check parameters are not nil |
| "Secret key not available" | Using public key | Use `list_keys(email, 1)` |
| "Invalid user ID" | Malformed format | Use "Name <email@example.com>" |
| "No such user ID" | UID doesn't match | Use exact string including case |

## Methods Summary

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `add_uid(key, userid, reserved=0)` | Key, String, Integer | nil | Add UID (sync) |
| `add_uid_start(key, userid, reserved=0)` | Key, String, Integer | nil | Add UID (async) |
| `revoke_uid(key, userid, reserved=0)` | Key, String, Integer | nil | Revoke UID (sync) |
| `revoke_uid_start(key, userid, reserved=0)` | Key, String, Integer | nil | Revoke UID (async) |

## Best Practices

1. **Consistent naming** - Use same name format across all UIDs
2. **Use comments** - Distinguish contexts: "Name (Work) <email>"
3. **Revoke promptly** - When you lose control of an email
4. **Verify format** - Always include email in angle brackets
5. **Publish changes** - Update keyservers after modifications

## Example Workflow

```ruby
# 1. Get your key
keys = ctx.list_keys("alice@example.com", 1)
key = keys.first

# 2. Add work email
ctx.add_uid(key, "Alice Smith (Work) <alice@work.com>")

# 3. Add project email
ctx.add_uid(key, "Alice Smith (Projects) <alice@projects.org>")

# 4. Later: revoke old work email
ctx.revoke_uid(key, "Alice Smith (Work) <alice@work.com>")

# 5. Add new work email
ctx.add_uid(key, "Alice Smith (Work) <alice@newjob.com>")

# 6. Publish updated key
# gpg --send-keys <KEYID>
```

## Testing

```bash
# Run UID specs
bundle exec rspec --example "uid"

# Run all specs
bundle exec rspec
```

## Documentation

- **Full Guide**: `docs/USER_ID_MANAGEMENT.md`
- **Examples**: `examples/uid_management_example.rb`
- **Summary**: `UID_MANAGEMENT_SUMMARY.md`

## Test Coverage

✅ 28 examples, 0 failures
- add_uid: 8 specs
- add_uid_start: 6 specs
- revoke_uid: 8 specs
- revoke_uid_start: 6 specs

## Security Notes

- User IDs are **public information**
- Revoked UIDs **remain visible** but marked invalid
- Only add emails **you control**
- **Publish updates** to keyservers after changes
