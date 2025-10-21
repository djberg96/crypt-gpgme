RSpec.shared_context 'with temporary gpg home', :tempfs do
  let(:original_home) { ENV['GNUPGHOME'] }
  let(:engine) { Crypt::GPGME::Context.new.get_engine_info.first }

  # The purpose here is to create a space where we can add, modify, or delete
  # keys without affecting your real keychain. To do this we create a temporary
  # directory, and generate a series of files that gpg needs to function
  # properly. We set GNUPGHOME for good measure.
  #
  around(:each) do |example|
    Dir.mktmpdir do |tmpdir|
      # Create all the things
      FileUtils.mkdir_p(tmpdir, mode: 0700)
      FileUtils.mkdir_p(File.join(tmpdir, 'private-keys-v1.d'), mode: 0700)
      FileUtils.mkdir_p(File.join(tmpdir, 'openpgp-revocs.d'), mode: 0700)
      FileUtils.mkdir_p(File.join(tmpdir, 'public-keys.d'), mode: 0755)

      FileUtils.touch(File.join(tmpdir, 'pubring.kbx'))
      FileUtils.touch(File.join(tmpdir, 'trustdb.gpg'))
      FileUtils.touch(File.join(tmpdir, 'sshcontrol'))
      FileUtils.touch(File.join(tmpdir, 'common.conf'))

      File.chmod(0600, File.join(tmpdir, 'trustdb.gpg'))
      File.chmod(0644, File.join(tmpdir, 'common.conf'))
      File.chmod(0600, File.join(tmpdir, 'sshcontrol'))

      # Set this special env variable just in case
      ENV['GNUPGHOME'] = tmpdir

      # Give the example a handle to the temporary directory if needed
      example.metadata[:tmpdir] = tmpdir

      # Run the example
      example.run

      # Restore original environment
      ENV['GNUPGHOME'] = original_home
    end
  end
end
