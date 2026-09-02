require 'test_helper'

class RubymemImporterTest < ActiveSupport::TestCase
  REPO_PATH = 'test/fixtures/files/rubymem_repo'.freeze

  def importer
    # The fixture repo is already on disk, so the git step is not exercised
    # here, GitHandlerTest covers it.
    RubymemImporter.new(REPO_PATH).tap do |imp|
      imp.define_singleton_method(:update_local_store!) { nil }
    end
  end

  test "imports every advisory file in the repository" do
    assert_difference 'RubymemAdvisory.count', 2 do
      importer.import!
    end

    identifiers = RubymemAdvisory.pluck(:identifier).sort
    assert_equal ['leaky_gem-670', 'other_gem-12'], identifiers
  end

  test "imported advisories are published and carry the parsed attributes" do
    importer.import!
    advisory = RubymemAdvisory.find_by!(identifier: 'leaky_gem-670')

    assert_equal true, advisory.imported
    assert_equal 'leaky_gem', advisory.gem
    assert_equal 'Memory leak in the connection pool', advisory.title
    # A Date in the YAML has to survive the load, Psych 4 rejects it by default.
    assert_equal Date.new(2015, 8, 31), advisory.date
    assert_equal ['>= 0.17.3'], advisory.patched_versions
    assert_equal ['< 0.16.0'], advisory.unaffected_versions
    assert_match 'Connections are never returned', advisory.description
    assert advisory.ident.present?, 'expected has_secure_token to fill in ident'
  end

  test "re-importing updates the existing advisory instead of duplicating it" do
    importer.import!
    advisory = RubymemAdvisory.find_by!(identifier: 'leaky_gem-670')
    advisory.update!(title: 'Stale title', imported: false)

    assert_no_difference 'RubymemAdvisory.count' do
      importer.import!
    end

    advisory.reload
    assert_equal 'Memory leak in the connection pool', advisory.title
    assert_equal true, advisory.imported
  end

  test "the identifier is built from the gem directory and the file name" do
    adapter = importer.parse(File.join(REPO_PATH, 'gems/other_gem/12.yml'))

    assert_equal 'other_gem-12', adapter.identifier
    assert_equal 'other_gem', adapter.gem
    assert_equal true, adapter.to_h['imported']
    assert_nil adapter.to_h['filepath'], 'filepath is internal and must not be stored'
  end

  test "fetch_advisories only picks up the yml files under gems/" do
    files = importer.fetch_advisories

    assert_equal 2, files.size
    assert files.all? { |f| f.end_with?('.yml') }
  end
end
