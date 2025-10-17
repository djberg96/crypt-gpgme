# Setting Owner Trust Levels

The `set_owner_trust` and `set_owner_trust_start` methods allow you to modify the owner trust level of OpenPGP keys in your keyring. Owner trust is a key concept in the Web of Trust model used by OpenPGP.

## Overview

- **Synchronous**: `set_owner_trust(key, value)`
- **Asynchronous**: `set_owner_trust_start(key, value)`

## Understanding Owner Trust

### What is Owner Trust?

**Owner trust** is YOUR assessment of how much you trust the key owner to properly verify and certify other people's keys. It's fundamentally different from key validity:

- **Owner Trust**: Your personal judgement about the key owner's trustworthiness as a key certifier
- **Key Validity**: Automatically calculated based on signatures and trust paths in the Web of Trust

### Trust Levels

| Level | String | Integer | Meaning |
|-------|--------|---------|---------|
| Unknown | `"unknown"` | `0` | Trust level is unknown |
| Undefined | `"undefined"` | `1` | Trust level has not been defined |
| Never | `"never"` | `2` | Never trust this key owner to certify other keys |
| Marginal | `"marginal"` | `3` | Marginally trust this key owner's certifications |
| Full | `"full"` | `4` | Fully trust this key owner to certify other keys |
| Ultimate | `"ultimate"` | `5` | Ultimate trust (typically only for your own keys) |

## Parameters

- `key`: The key to modify (Crypt::GPGME::Key or Structs::Key)
- `value`: Trust value as a String ("unknown", "undefined", "never", "marginal", "full", "ultimate") or Integer (0-5)

## Basic Usage

### Set trust using string values

```ruby
require 'crypt/gpgme'

ctx = Crypt::GPGME::Context.new
key = ctx.list_keys("user@example.com").first

# Set full trust
ctx.set_owner_trust(key, "full")

# Set marginal trust
ctx.set_owner_trust(key, "marginal")

# Set ultimate trust (for your own keys)
ctx.set_owner_trust(key, "ultimate")

# Never trust
ctx.set_owner_trust(key, "never")
```

### Set trust using integer values

```ruby
# Using integer constants
ctx.set_owner_trust(key, 4)  # Full trust
ctx.set_owner_trust(key, 5)  # Ultimate trust
ctx.set_owner_trust(key, 3)  # Marginal trust

# Using GPGME constants
ctx.set_owner_trust(key, Crypt::GPGME::GPGME_VALIDITY_FULL)
ctx.set_owner_trust(key, Crypt::GPGME::GPGME_VALIDITY_ULTIMATE)
ctx.set_owner_trust(key, Crypt::GPGME::GPGME_VALIDITY_MARGINAL)
```

### Case-insensitive string values

```ruby
# All of these work (converted to lowercase internally)
ctx.set_owner_trust(key, "FULL")
ctx.set_owner_trust(key, "Full")
ctx.set_owner_trust(key, "full")
```

## Asynchronous Operation

Use `set_owner_trust_start` for asynchronous operations:

```ruby
ctx.set_owner_trust_start(key, "full")
# Do other work...
ctx.wait  # Wait for operation to complete
```

## Checking Current Owner Trust

```ruby
key = ctx.list_keys("user@example.com").first

# Owner trust is an integer (0-5)
trust = key.owner_trust

case trust
when 0
  puts "Unknown trust"
when 1
  puts "Undefined trust"
when 2
  puts "Never trust"
when 3
  puts "Marginal trust"
when 4
  puts "Full trust"
when 5
  puts "Ultimate trust"
end
```

## Web of Trust Calculations

### How Trust Affects Validity

Owner trust directly impacts how GPGME calculates the validity of other keys:

1. **Ultimate Trust**: All keys signed by this key owner are considered fully valid
2. **Full Trust**: One fully-trusted signature can make a key valid
3. **Marginal Trust**: Multiple marginally-trusted signatures are needed (typically 3)
4. **Never**: Signatures from this key are ignored in validity calculations

### Example Scenario

```ruby
# Your own key - set to ultimate trust
my_key = ctx.list_keys("me@example.com").first
ctx.set_owner_trust(my_key, "ultimate")

# A colleague you trust completely to verify others
colleague = ctx.list_keys("colleague@example.com").first
ctx.set_owner_trust(colleague, "full")

# An acquaintance you somewhat trust
acquaintance = ctx.list_keys("acquaintance@example.com").first
ctx.set_owner_trust(acquaintance, "marginal")

# Someone you don't trust at all
untrusted = ctx.list_keys("spam@example.com").first
ctx.set_owner_trust(untrusted, "never")
```

## Important Notes

### 1. OpenPGP Only
Owner trust is specific to OpenPGP (GPG) keys. It's not applicable to S/MIME or other protocols.

```ruby
# Make sure you're working with OpenPGP keys
ctx.set_protocol(Crypt::GPGME::GPGME_PROTOCOL_OpenPGP)
```

### 2. Personal Assessment
Owner trust is stored locally in your trustdb. It's YOUR personal judgement and is not shared with others.

### 3. Ultimate Trust Guidelines
Only set **ultimate trust** for keys you personally control:
- Your own keys
- Keys where you have the private key
- Never for other people's keys, no matter how much you trust them

### 4. Full Trust Implications
Setting **full trust** means you trust this person's judgement about key verification as much as your own. Use carefully.

### 5. Permissions
This operation modifies your local trustdb, which may require appropriate file system permissions.

## Error Handling

```ruby
begin
  ctx.set_owner_trust(key, "full")
  puts "Owner trust updated successfully"
rescue ArgumentError => e
  puts "Invalid trust value: #{e.message}"
rescue Crypt::GPGME::Error => e
  puts "Failed to update owner trust: #{e.message}"
end
```

## Common Patterns

### Trust Your Own Keys

```ruby
# Find and trust all your own keys
my_keys = ctx.list_keys(nil, 1)  # secret=1 finds your own keys
my_keys.each do |key|
  ctx.set_owner_trust(key, "ultimate")
  puts "Set ultimate trust for: #{key.uids.first.uid}"
end
```

### Set Default Trust Level

```ruby
# Set all imported keys to undefined by default
keys = ctx.list_keys
keys.each do |key|
  if key.owner_trust == 0  # Unknown
    ctx.set_owner_trust(key, "undefined")
  end
end
```

### Trust Based on Key Type

```ruby
key = ctx.list_keys("user@example.com").first

# Check if it's your own key (has secret key)
if key.secret?
  ctx.set_owner_trust(key, "ultimate")
else
  # External key - set appropriate trust
  ctx.set_owner_trust(key, "marginal")
end
```

## Constants Reference

Available in `Crypt::GPGME` module:

```ruby
GPGME_VALIDITY_UNKNOWN   = 0
GPGME_VALIDITY_UNDEFINED = 1
GPGME_VALIDITY_NEVER     = 2
GPGME_VALIDITY_MARGINAL  = 3
GPGME_VALIDITY_FULL      = 4
GPGME_VALIDITY_ULTIMATE  = 5
```

## See Also

- [GPGME Manual - Key Management](https://www.gnupg.org/documentation/manuals/gpgme/)
- [The GNU Privacy Handbook - Web of Trust](https://www.gnupg.org/gph/en/manual/x334.html)
- `examples/set_owner_trust_example.rb` for a complete working example
- Related method: `set_expire` for setting key expiration times
