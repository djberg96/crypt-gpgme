# Setting Key Expiration Times

The `set_expire` and `set_expire_start` methods allow you to modify the expiration time of keys and subkeys in your keyring.

## Overview

- **Synchronous**: `set_expire(key, expires, subfprs = nil, reserved = 0)`
- **Asynchronous**: `set_expire_start(key, expires, subfprs = nil, reserved = 0)`

## Parameters

- `key`: The key to modify (Crypt::GPGME::Key or Structs::Key)
- `expires`: Expiration time in seconds from now, or 0 for no expiration
- `subfprs`: Optional newline-separated fingerprints of subkeys to modify (nil = primary key only)
- `reserved`: Reserved parameter, must be 0

## Basic Usage

### Set primary key to expire in 1 year

```ruby
require 'crypt/gpgme'

ctx = Crypt::GPGME::Context.new
key = ctx.list_keys("user@example.com").first

# Set to expire in 1 year (365 days * 24 hours * 60 minutes * 60 seconds)
one_year = 365 * 24 * 60 * 60
ctx.set_expire(key, one_year)
```

### Set primary key to never expire

```ruby
# A value of 0 means no expiration
ctx.set_expire(key, 0)
```

### Set specific subkeys to expire

```ruby
# Get subkey fingerprints
subkey1_fpr = key.subkeys[1].fpr
subkey2_fpr = key.subkeys[2].fpr

# Join with newlines for multiple subkeys
subfprs = "#{subkey1_fpr}\n#{subkey2_fpr}"

# Set these specific subkeys to expire in 6 months
six_months = 180 * 24 * 60 * 60
ctx.set_expire(key, six_months, subfprs)
```

## Asynchronous Operation

Use `set_expire_start` for asynchronous operations:

```ruby
ctx.set_expire_start(key, one_year)
# Do other work...
ctx.wait  # Wait for operation to complete
```

## Important Notes

1. **Authentication Required**: This operation requires the key's passphrase. You'll be prompted via pinentry or need to set up a passphrase callback.

2. **Relative Time**: The `expires` parameter is relative to the current time, not an absolute timestamp.

3. **Permission Required**: You must have permission to modify the key (typically this means it's your own key).

4. **Primary Key vs Subkeys**:
   - If `subfprs` is `nil`, only the primary key's expiration is changed
   - To change subkeys, provide their fingerprints in the `subfprs` parameter

## Common Expiration Periods

```ruby
# Common time periods in seconds
ONE_HOUR   = 60 * 60
ONE_DAY    = 24 * ONE_HOUR
ONE_WEEK   = 7 * ONE_DAY
ONE_MONTH  = 30 * ONE_DAY
SIX_MONTHS = 180 * ONE_DAY
ONE_YEAR   = 365 * ONE_DAY
TWO_YEARS  = 730 * ONE_DAY

# Set key to expire in 2 years
ctx.set_expire(key, TWO_YEARS)
```

## Error Handling

```ruby
begin
  ctx.set_expire(key, one_year)
  puts "Key expiration updated successfully"
rescue Crypt::GPGME::Error => e
  puts "Failed to update key expiration: #{e.message}"
end
```

## Viewing Current Expiration

```ruby
key = ctx.list_keys("user@example.com").first

# Check primary key expiration
if key.expires > 0
  puts "Key expires: #{Time.at(key.expires)}"
else
  puts "Key never expires"
end

# Check subkey expirations
key.subkeys.each do |subkey|
  if subkey.expires > 0
    puts "Subkey #{subkey.keyid} expires: #{Time.at(subkey.expires)}"
  else
    puts "Subkey #{subkey.keyid} never expires"
  end
end
```

## See Also

- [GPGME Manual - Key Management](https://www.gnupg.org/documentation/manuals/gpgme/)
- `examples/set_expire_example.rb` for a complete working example
