require 'test_helper'
require 'tmpdir'
require 'open3'
require Rails.root.join('lib/git_handler')

class GitHandlerTest < ActiveSupport::TestCase
  # Uses a local repository as the remote, so the test needs no network access.
  def with_source_repo
    Dir.mktmpdir do |dir|
      source = File.join(dir, 'source')
      FileUtils.mkdir_p(File.join(source, 'gems'))
      File.write(File.join(source, 'gems', 'advisory.yml'), "gem: leaky_gem\n")
      Dir.chdir(source) do
        system('git init --quiet .')
        system('git config user.email test@example.com')
        system('git config user.name Test')
        system('git add . && git commit --quiet -m "first advisory"')
      end
      yield source, File.join(dir, 'clone')
    end
  end

  test "clones the repository when the local copy is missing" do
    with_source_repo do |source, local|
      GitHandler.new(RubymemImporter, source, local).fetch_and_update_repo!

      assert File.exist?(File.join(local, 'gems', 'advisory.yml'))
    end
  end

  test "pulls new commits when the local copy already exists" do
    with_source_repo do |source, local|
      handler = GitHandler.new(RubymemImporter, source, local)
      handler.fetch_and_update_repo!

      Dir.chdir(source) do
        File.write(File.join(source, 'gems', 'second.yml'), "gem: other_gem\n")
        system('git add . && git commit --quiet -m "second advisory"')
      end

      handler.fetch_and_update_repo!

      assert File.exist?(File.join(local, 'gems', 'second.yml'))
    end
  end

  test "raises with the git output when cloning fails" do
    Dir.mktmpdir do |dir|
      handler = GitHandler.new(RubymemImporter, File.join(dir, 'nope'), File.join(dir, 'clone'))

      error = assert_raises(RuntimeError) { handler.fetch_and_update_repo! }
      assert_match 'RubymemImporter', error.message
      assert_match 'something went wrong', error.message
    end
  end
end
