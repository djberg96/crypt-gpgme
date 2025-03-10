require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'crypt-gpgme'
  spec.version    = '0.1.0'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://github.com/djberg96/crypt-gpgme'
  spec.summary    = 'An interface for GPG Made Easy (GPGME)'
  spec.license    = 'Apache-2.0'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') } 
  spec.test_files = Dir['spec/*_spec.rb']
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files = Dir['doc/*.rdoc']

  spec.add_dependency('ffi', '~> 1.1')

  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_boolean')
  spec.add_development_dependency('mkmf-lite')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-rspec')

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/crypt-gpgme',
    'bug_tracker_uri'       => 'https://github.com/djberg96/crypt-gpgme/issues',
    'changelog_uri'         => 'https://github.com/djberg96/crypt-gpgme/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/crypt-gpgme/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/crypt-gpgme',
    'wiki_uri'              => 'https://github.com/djberg96/crypt-gpgme/wiki',
    'rubygems_mfa_required' => 'true',
    'github_repo'           => 'https://github.com/djberg96/crypt-gpgme',
    'funding_uri'           => 'https://github.com/sponsors/djberg96'
  }

  spec.description = <<-EOF
    The crypt-gpgme library provides an interface for the GPGME library (GPG
    Made Easy).
  EOF
end
