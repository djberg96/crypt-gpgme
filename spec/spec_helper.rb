#######################################################################
# spec_helper.rb
#
# Common configuration and helpers for all spec files.
#######################################################################
require 'rspec'
require 'rspec_boolean'
require 'crypt/gpgme'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use color in output
  config.color = true

  # Use documentation format by default
  config.default_formatter = 'doc' if config.files_to_run.one?
end
