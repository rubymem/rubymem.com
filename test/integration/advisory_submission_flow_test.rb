require 'test_helper'

class AdvisorySubmissionFlowTest < ActionDispatch::IntegrationTest
  def advisory_params(overrides = {})
    { advisory_presenter: {
      gem: 'leaky_gem',
      date: '2016-12-31',
      url: 'https://example.com/leak',
      title: 'Memory leak in the connection pool',
      description: 'Connections are never returned to the pool.',
      unaffected_versions: "< 1.2.3\r\n~> 1.2",
      patched_versions: "> 1.2.3\r\n~> 3.2",
      related_links: "https://example.com/commit",
      submitter_email: 'reporter@example.com'
    }.merge(overrides) }
  end

  test "the form posts to the preview action" do
    get new_advisory_path

    assert_response :success
    assert_select "form#advisory-form[action=?]", preview_advisories_path do
      assert_select "input[name=?]", 'advisory_presenter[gem]'
      assert_select "input[name=?]", 'advisory_presenter[date]'
      assert_select "input[name=?]", 'advisory_presenter[url]'
      assert_select "input[name=?]", 'advisory_presenter[title]'
      assert_select "textarea[name=?]", 'advisory_presenter[description]'
      assert_select "textarea[name=?]", 'advisory_presenter[unaffected_versions]'
      assert_select "textarea[name=?]", 'advisory_presenter[patched_versions]'
      assert_select "textarea[name=?]", 'advisory_presenter[related_links]'
      assert_select "input[name=?]", 'advisory_presenter[submitter_email]'
    end
    assert_select '#submit-review', false,
                  'the submit button belongs to the preview, not to the empty form'
  end

  test "previewing renders the advisory YAML without storing anything" do
    assert_no_difference 'RubymemAdvisory.count' do
      post preview_advisories_path, params: advisory_params
    end

    assert_response :success
    yaml = YAML.safe_load(css_select('pre').first.text, permitted_classes: [Date])
    assert_equal 'leaky_gem', yaml['gem']
    assert_equal 'Memory leak in the connection pool', yaml['title']
    assert_equal Date.new(2016, 12, 31), yaml['date']
    assert_equal ['< 1.2.3', '~> 1.2'], yaml['unaffected_versions']
    assert_equal ['> 1.2.3', '~> 3.2'], yaml['patched_versions']
    assert_select '#submit-review[formaction=?]', advisories_path
  end

  test "creating stores the advisory, parses the version lists and notifies the reviewers" do
    assert_difference 'RubymemAdvisory.count', 1 do
      assert_emails 1 do
        post advisories_path, params: advisory_params
      end
    end

    assert_response :success
    assert_select 'h1', 'Awesome! Thanks for your help.'

    advisory = RubymemAdvisory.last
    assert_equal 'leaky_gem', advisory.gem
    assert_equal Date.new(2016, 12, 31), advisory.date
    assert_equal 'https://example.com/leak', advisory.url
    assert_equal 'Connections are never returned to the pool.', advisory.description
    # The textareas are line separated and arrive with CRLF, both lists are split
    # and stripped.
    assert_equal ['< 1.2.3', '~> 1.2'], advisory.unaffected_versions
    assert_equal ['> 1.2.3', '~> 3.2'], advisory.patched_versions
    assert_equal ['https://example.com/commit'], advisory.related_links
    assert_equal 'reporter@example.com', advisory.submitter_email

    mail = ActionMailer::Base.deliveries.last
    assert_equal ['hello@ombulabs.com'], mail.to
    assert_equal 'New Rubymem submission!', mail.subject
    assert_match 'reporter@example.com', mail.body.to_s
  end

  test "a submission is held back from the archive until it is reviewed" do
    post advisories_path, params: advisory_params

    advisory = RubymemAdvisory.last
    assert_equal false, advisory.imported
    assert_empty RubymemAdvisory.imported

    get advisories_path
    assert_response :success
    assert_select 'table.table td', text: 'leaky_gem', count: 0
  end

  test "a submitter cannot publish their own advisory" do
    post advisories_path, params: advisory_params(imported: true)

    assert_equal false, RubymemAdvisory.last.imported
  end

  test "a submitter cannot set the identifier or the token" do
    post advisories_path, params: advisory_params(identifier: 'forged', ident: 'forged')

    advisory = RubymemAdvisory.last
    assert_nil advisory.identifier
    refute_equal 'forged', advisory.ident
  end

  test "the archive lists reviewed advisories, most recent first, and links to each one" do
    older = FactoryBot.create(:rubymem_advisory, imported: true, title: 'Older leak',
                              date: Date.new(2015, 1, 1))
    newer = FactoryBot.create(:rubymem_advisory, imported: true, title: 'Newer leak',
                              date: Date.new(2017, 1, 1))
    unreviewed = FactoryBot.create(:rubymem_advisory, imported: false,
                                   title: 'Unreviewed leak')

    get advisories_path

    assert_response :success
    assert_select 'table.table td a', count: 2
    titles = css_select('table.table td a').map(&:text)
    assert_equal [newer.title, older.title], titles
    refute_includes titles, unreviewed.title
    assert_select "table.table td a[href=?]", advisory_path(newer)
  end

  test "an advisory page renders the published YAML" do
    advisory = FactoryBot.create(:rubymem_advisory, imported: true, gem: 'leaky_gem')

    get advisory_path(advisory)

    assert_response :success
    yaml = YAML.safe_load(css_select('pre').first.text, permitted_classes: [Date])
    assert_equal 'leaky_gem', yaml['gem']
    assert_equal advisory.title, yaml['title']
    assert_select "a[href=?]", advisories_path
  end

  test "an unknown advisory is a 404" do
    get advisory_path(id: 'does-not-exist')

    assert_response :not_found
  end

  # Characterization tests: these lock in behavior that is currently wrong, so a
  # fix has to update them deliberately rather than by accident.

  test "CHARACTERIZATION an empty submission is accepted and stored" do
    assert_difference 'RubymemAdvisory.count', 1 do
      post advisories_path, params: { advisory_presenter: { gem: '', title: '' } }
    end

    assert_response :success
    assert_equal '', RubymemAdvisory.last.gem
  end

  test "CHARACTERIZATION the notification is sent even when the advisory is not saved" do
    # `create` calls the mailer outside the `unless @advisory.save` guard, so a
    # failed save renders the preview and then looks up a nil id, which is a 500.
    RubymemAdvisory.class_eval { validates :title, presence: true }

    post advisories_path, params: advisory_params(title: '')

    assert_response :internal_server_error
  ensure
    RubymemAdvisory.clear_validators!
  end
end
