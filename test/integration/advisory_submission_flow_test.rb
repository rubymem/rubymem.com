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
    # Three steps, matching what the flow actually does.
    assert_select 'ol li', count: 3
    assert_select 'ol li', text: /Fill out the form/
    assert_select 'ol li', text: /Review the preview/
    assert_select 'ol li', text: /Submit for review/
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
    # One submit button, in the form. The old duplicate needed JavaScript.
    assert_select '#submit-review-link', false
    assert_select 'input[type=submit]', count: 2
    assert_select 'input[value=?]', 'Update preview'
    assert_match 'Nothing has been saved yet', response.body
  end

  test "previewing an incomplete advisory comes back to the form with the errors" do
    assert_no_difference 'RubymemAdvisory.count' do
      post preview_advisories_path, params: advisory_params(url: '', submitter_email: '')
    end

    assert_response :unprocessable_entity
    assert_select '#error_explanation li', text: "Url can't be blank"
    assert_select '#error_explanation li', text: "Submitter email can't be blank"
    # No YAML and no submit button until the advisory is complete.
    assert_select 'pre', false
    assert_select '#submit-review', false
    assert_select "input[name=?][value=?]", 'advisory_presenter[gem]', 'leaky_gem'
  end

  test "creating stores the advisory, parses the version lists and notifies the reviewers" do
    assert_difference 'RubymemAdvisory.count', 1 do
      assert_emails 1 do
        post advisories_path, params: advisory_params
      end
    end

    # Redirected, so refreshing the thank-you page cannot submit again.
    assert_redirected_to thanks_advisories_path
    follow_redirect!
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

  test "refreshing the thank-you page submits nothing" do
    post advisories_path, params: advisory_params

    assert_no_difference 'RubymemAdvisory.count' do
      assert_no_emails do
        3.times { get thanks_advisories_path }
      end
    end

    assert_response :success
    assert_select 'h1', 'Awesome! Thanks for your help.'
    # The page has to say what was sent and what happens next.
    assert_match 'the reviewers have been emailed', response.body
    assert_match 'not published yet', response.body
    assert_select "a[href=?]", advisories_path
    assert_select "a[href='https://github.com/rubymem/ruby-mem-advisory-db']"
  end

  test "the errors on the preview page can be fixed and submitted again" do
    post advisories_path, params: advisory_params(url: '', submitter_email: '')

    assert_response :unprocessable_entity
    # Both buttons are still there and still point where they should.
    assert_select "form#advisory-form[action=?]", preview_advisories_path
    assert_select "input[value=?]", 'Update preview'
    assert_select "#submit-review[formaction=?]", advisories_path

    assert_difference 'RubymemAdvisory.count', 1 do
      assert_emails 1 do
        post advisories_path, params: advisory_params
      end
    end

    assert_redirected_to thanks_advisories_path
  end

  test "the errors on the form can be previewed again once fixed" do
    post preview_advisories_path, params: advisory_params(url: '')

    assert_response :unprocessable_entity
    assert_select "form#advisory-form[action=?]", preview_advisories_path
    assert_select "input[value=?]", 'Preview'

    post preview_advisories_path, params: advisory_params

    assert_response :success
    assert_select '#submit-review'
    assert_select 'pre', /gem: leaky_gem/
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

  test "an empty submission is rejected" do
    assert_no_difference 'RubymemAdvisory.count' do
      assert_no_emails do
        post advisories_path, params: { advisory_presenter: { gem: '', title: '' } }
      end
    end

    assert_response :unprocessable_entity
  end

  test "an incomplete submission comes back as the preview, listing what is missing" do
    assert_no_difference 'RubymemAdvisory.count' do
      assert_no_emails do
        post advisories_path, params: advisory_params(url: '', submitter_email: '')
      end
    end

    assert_response :unprocessable_entity
    assert_select '#error_explanation li', text: "Url can't be blank"
    assert_select '#error_explanation li', text: "Submitter email can't be blank"
    # The submitter gets the form back with what they typed, plus the preview.
    assert_select "input[name=?][value=?]", 'advisory_presenter[gem]', 'leaky_gem'
    assert_select '#submit-review'
    assert_select 'pre', /gem: leaky_gem/
  end

  test "the reviewers are not notified when the submission is rejected" do
    post advisories_path, params: advisory_params(title: '')

    assert_response :unprocessable_entity
    assert_empty ActionMailer::Base.deliveries
  end
end
