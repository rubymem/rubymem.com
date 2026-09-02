require 'test_helper'

class AdvisoriesControllerTest < ActionDispatch::IntegrationTest
  test "index lists the reviewed advisories" do
    advisories = FactoryBot.create_list(:rubymem_advisory, 5, imported: true)
    FactoryBot.create(:rubymem_advisory, imported: false, gem: 'unreviewed_gem')

    get advisories_path

    assert_response :success
    assert_select 'table.table td a', count: advisories.size
    gems = css_select('table.table td:nth-child(2)').map(&:text).map(&:strip)
    assert_equal advisories.map(&:gem).sort, gems.sort
    refute_includes gems, 'unreviewed_gem'
  end

  test "index paginates the archive" do
    FactoryBot.create_list(:rubymem_advisory, WillPaginate.per_page + 1, imported: true)

    get advisories_path
    assert_select 'table.table td a', count: WillPaginate.per_page
    assert_select 'ul.pagination'

    get advisories_path, params: { page: 2 }
    assert_select 'table.table td a', count: 1
  end

  test "show renders the advisory YAML" do
    advisory = FactoryBot.create(:rubymem_advisory, imported: true)

    get advisory_path(advisory)

    assert_response :success
    assert_select 'pre', /gem: #{advisory.gem}/
  end

  test "new renders the submission form" do
    get new_advisory_path

    assert_response :success
    assert_select 'form#advisory-form[action=?]', preview_advisories_path
  end

  test "preview renders the YAML and stores nothing" do
    assert_no_difference 'RubymemAdvisory.count' do
      post preview_advisories_path, params: advisory_params
    end

    assert_response :success
    assert_select 'pre', /gem: fake/
  end

  test "create stores the submission, notifies the reviewers and keeps it unpublished" do
    assert_difference 'RubymemAdvisory.count', 1 do
      assert_emails 1 do
        post advisories_path, params: advisory_params
      end
    end

    assert_response :success
    advisory = RubymemAdvisory.last

    # we parsed out line separated strings properly
    assert_equal ['< 1.2.3', '~> 1.2,', '> 3.2'], advisory.unaffected_versions
    assert_equal ['~> 1.2.3', '> 1.2'], advisory.patched_versions
    assert_equal false, advisory.imported
  end

  def advisory_params
    {advisory_presenter: {
      gem: "fake",
      date: "2016-12-31",
      title: "this is a title",
      description: "desc",
      patched_versions: "~> 1.2.3\r\n> 1.2",
      unaffected_versions: "< 1.2.3\r\n~> 1.2,\r\n> 3.2",
      imported: true,
      submitter_email: "foo@example.com"
    }}

  end
end
