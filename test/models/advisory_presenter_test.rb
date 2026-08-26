require 'test_helper'

class AdvisoryPresenterTest < ActiveSupport::TestCase
  test "the version and link arrays are presented one entry per line" do
    advisory = RubymemAdvisory.new(unaffected_versions: ['< 1.2.3', '~> 1.2'],
                                   patched_versions: ['> 1.2.3', '~> 3.2'],
                                   related_links: ['https://example.com/a',
                                                   'https://example.com/b'])

    presenter = AdvisoryPresenter.new(advisory)

    assert_equal "< 1.2.3\n~> 1.2", presenter.unaffected_versions
    assert_equal "> 1.2.3\n~> 3.2", presenter.patched_versions
    assert_equal "https://example.com/a\nhttps://example.com/b", presenter.related_links
  end

  test "the arrays are optional" do
    presenter = AdvisoryPresenter.new(RubymemAdvisory.new(unaffected_versions: nil,
                                                          patched_versions: nil,
                                                          related_links: nil))

    assert_nil presenter.unaffected_versions
    assert_nil presenter.patched_versions
    assert_nil presenter.related_links
  end

  test "the plain advisory fields are delegated" do
    advisory = RubymemAdvisory.new(gem: 'leaky_gem', title: 'Memory leak',
                                   date: Date.new(2016, 12, 31),
                                   url: 'https://example.com/leak',
                                   description: 'It leaks.',
                                   submitter_email: 'reporter@example.com')

    presenter = AdvisoryPresenter.new(advisory)

    assert_equal 'leaky_gem', presenter.gem
    assert_equal 'Memory leak', presenter.title
    assert_equal Date.new(2016, 12, 31), presenter.date
    assert_equal 'https://example.com/leak', presenter.url
    assert_equal 'It leaks.', presenter.description
    assert_equal 'reporter@example.com', presenter.submitter_email
    assert_same advisory, presenter.advisory
  end

  test "the presenter names the form fields after advisory_presenter" do
    presenter = AdvisoryPresenter.new(RubymemAdvisory.new)

    assert_equal 'advisory_presenter', AdvisoryPresenter.model_name.param_key
    # form_for only calls persisted? when the presenter responds to it, and this
    # one does not, so the form always posts to the preview URL.
    refute_respond_to presenter, :persisted?
  end
end
