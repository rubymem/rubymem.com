require 'test_helper'

class AdvisoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    FactoryBot.create_list(:rubymem_advisory, 5)
    get advisories_path
    assert_response :success
  end

  test "should get show" do
    advisory = FactoryBot.create(:rubymem_advisory)
    get advisory_path(advisory)
    assert_response :success
  end

  test "should get new" do
    get new_advisory_path
    assert_response :success
  end

  test "should post preview" do
    post preview_advisories_path, params: advisory_params

    assert_response :success
  end

  test "should create advisories" do
    assert_equal 0, RubymemAdvisory.count
    post advisories_path, params: advisory_params

    assert_equal 1, RubymemAdvisory.count
    assert_response :success

    # we parsed out line separated strings properly
    adv = RubymemAdvisory.first

    assert_equal 3, adv.unaffected_versions.count
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
