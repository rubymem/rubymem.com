require 'application_system_test_case'

class AdvisorySubmissionTest < ApplicationSystemTestCase
  def fill_in_advisory_form
    fill_in 'advisory_presenter_gem', with: 'leaky_gem'
    fill_in 'advisory_presenter_date', with: '2016-12-31'
    fill_in 'advisory_presenter_url', with: 'https://example.com/leak'
    fill_in 'advisory_presenter_title', with: 'Memory leak in leaky_gem'
    fill_in 'advisory_presenter_description', with: 'The connection pool is never released.'
    fill_in 'advisory_presenter_unaffected_versions', with: "< 1.2.3\n~> 1.2"
    fill_in 'advisory_presenter_patched_versions', with: "> 1.2.3\n~> 3.2"
    fill_in 'advisory_presenter_related_links', with: 'https://example.com/commit'
    fill_in 'advisory_presenter_submitter_email', with: 'reporter@example.com'
  end

  test 'the form is rendered with every field a submitter has to fill in' do
    visit new_advisory_path

    assert_selector 'form#advisory-form'
    %w[gem date url title description unaffected_versions patched_versions
       related_links submitter_email].each do |field|
      assert_selector "form#advisory-form ##{"advisory_presenter_#{field}"}"
    end
    assert_selector "input[type=submit][value=Preview]"
    # The submit button only shows up once the submitter has seen a preview.
    assert_no_selector '#submit-review'
  end

  test 'previewing shows the generated YAML and persists nothing' do
    visit new_advisory_path
    fill_in_advisory_form

    assert_no_difference 'RubymemAdvisory.count' do
      click_button 'Preview'
    end

    assert_text 'Advisory YAML'
    within 'pre' do
      assert_text 'gem: leaky_gem'
      assert_text 'title: Memory leak in leaky_gem'
      assert_text '- "> 1.2.3"'
      assert_text '- "~> 3.2"'
    end
    assert_text 'reporter@example.com'
    # The preview keeps what was typed, so the submitter can revise it.
    assert_field 'advisory_presenter_gem', with: 'leaky_gem'
    assert_selector '#submit-review'
  end

  test 'submitting the previewed advisory stores it and thanks the submitter' do
    visit new_advisory_path
    fill_in_advisory_form
    click_button 'Preview'

    assert_difference 'RubymemAdvisory.count', 1 do
      find('#submit-review').click
    end

    assert_text 'Awesome! Thanks for your help.'

    advisory = RubymemAdvisory.last
    assert_equal 'leaky_gem', advisory.gem
    assert_equal Date.new(2016, 12, 31), advisory.date
    assert_equal ['< 1.2.3', '~> 1.2'], advisory.unaffected_versions
    assert_equal ['> 1.2.3', '~> 3.2'], advisory.patched_versions
    assert_equal ['https://example.com/commit'], advisory.related_links
    assert_equal 'reporter@example.com', advisory.submitter_email
  end

  test 'a submitted advisory is not published on the archive until it is imported' do
    visit new_advisory_path
    fill_in_advisory_form
    click_button 'Preview'
    find('#submit-review').click

    assert_equal false, RubymemAdvisory.last.imported

    visit advisories_path
    assert_no_text 'Memory leak in leaky_gem'
  end

  test 'the archive lists imported advisories, most recent first' do
    old = FactoryBot.create(:rubymem_advisory, imported: true, title: 'Older leak',
                            date: Date.new(2016, 1, 1))
    recent = FactoryBot.create(:rubymem_advisory, imported: true, title: 'Recent leak',
                               date: Date.new(2016, 12, 31))
    FactoryBot.create(:rubymem_advisory, imported: false, title: 'Unreviewed leak')

    visit advisories_path

    assert_text 'Recent leak'
    assert_text 'Older leak'
    assert_no_text 'Unreviewed leak'
    # The archive table has no <tbody>, so match the title cell directly.
    titles = all('table.table tr td:nth-child(3)').map(&:text)
    assert_equal [recent.title, old.title], titles

    click_link 'Recent leak'
    assert_text "gem: #{recent.gem}"
  end
end
