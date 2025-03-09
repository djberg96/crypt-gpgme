#######################################################################
# crypt_gpgme_spec.rb
#
# Specs for the crypt-gpgme library.
#######################################################################
require 'rspec'
require 'crypt/gpgme'

RSpec.describe Crypt::GPGME do
  example 'version is set to expected value' do
    expect(Crypt::GPGME::VERSION).to eq('0.1.0')
  end
end
