#######################################################################
# version_spec.rb
#
# Specs for the main Crypt::GPGME module version.
#######################################################################
require 'spec_helper'

RSpec.describe Crypt::GPGME do
  example 'version constant is set to expected value' do
    expect(Crypt::GPGME::VERSION).to eq('0.1.0')
  end

  example 'VERSION constant is a string' do
    expect(Crypt::GPGME::VERSION).to be_a(String)
  end
end
