require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_path
    assert_response :success
  end

  test "the atom feed lists the reviewed advisories, most recent first" do
    older = FactoryBot.create(:rubymem_advisory, imported: true, title: 'Older leak',
                              date: Date.new(2015, 1, 1))
    newer = FactoryBot.create(:rubymem_advisory, imported: true, title: 'Newer leak',
                              date: Date.new(2017, 1, 1))
    FactoryBot.create(:rubymem_advisory, imported: false, title: 'Unreviewed leak')

    get feed_path

    assert_response :success
    feed = Nokogiri::XML(response.body)
    titles = feed.css('entry title').map(&:text)
    assert_equal ['Newer leak', 'Older leak'], titles
    refute_includes titles, 'Unreviewed leak'
    assert_equal [advisory_url(newer), advisory_url(older)],
                 feed.css('entry link').map { |link| link['href'] }
    assert_equal [newer.identifier, older.identifier], feed.css('entry id').map(&:text)
  end

  test "the atom feed is capped at 20 entries" do
    FactoryBot.create_list(:rubymem_advisory, 21, imported: true)

    get feed_path

    assert_equal 20, Nokogiri::XML(response.body).css('entry').size
  end

  test "the atom feed renders when there is nothing to report" do
    get feed_path

    assert_response :success
    assert_empty Nokogiri::XML(response.body).css('entry')
  end
end
