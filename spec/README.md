# Spec Directory

This directory contains RSpec tests for the crypt-gpgme library.

## Spec Files

The specs are organized into separate files by class/module:

- **`spec_helper.rb`** - Common configuration and setup for all specs
- **`crypt_gpgme_version_spec.rb`** - Tests for the main `Crypt::GPGME` module version constant
- **`algorithm_spec.rb`** - Tests for `Crypt::GPGME::Algorithm` class
- **`engine_spec.rb`** - Tests for `Crypt::GPGME::Engine` class
- **`context_spec.rb`** - Tests for `Crypt::GPGME::Context` class
- **`structs_spec.rb`** - Tests for FFI struct bindings (`Crypt::GPGME::Structs::*`)
- **`crypt_gpgme_spec.rb`** - *(Deprecated)* Original combined spec file, kept for backward compatibility

## Running Specs

Run all specs:
```bash
bundle exec rspec
```

Run a specific spec file:
```bash
bundle exec rspec spec/context_spec.rb
```

Run with documentation format:
```bash
bundle exec rspec --format documentation
```

Run only failing specs:
```bash
bundle exec rspec --only-failures
```

## Notes

- The `context_spec.rb` file may cause a gpgrt ABI mismatch warning at the end when run with other specs. This is a known issue with the GPG runtime library cleanup and doesn't affect the test results.
- The original `crypt_gpgme_spec.rb` file is kept for backward compatibility but new tests should be added to the appropriate separate spec files.
