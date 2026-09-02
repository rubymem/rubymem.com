require 'test_helper'

class RubymemMailerTest < ActionMailer::TestCase
  test "the submission notification carries the advisory YAML and the reporter" do
    advisory = FactoryBot.create(:rubymem_advisory,
                                 gem: 'leaky_gem',
                                 title: 'Memory leak',
                                 submitter_email: 'reporter@example.com')

    mail = RubymemMailer.new_advisory(advisory.id)

    assert_equal 'New Rubymem submission!', mail.subject
    assert_equal ['rubymem <noreply@rubymem.com>'], mail.header[:from].formatted
    assert_equal ['hello@ombulabs.com'], mail.to
    assert_match 'reporter@example.com', mail.body.to_s
    assert_match 'gem: leaky_gem', mail.body.to_s
    assert_match 'title: Memory leak', mail.body.to_s
  end

  test "production notifications go to the reviewers address" do
    advisory = FactoryBot.create(:rubymem_advisory)

    Rails.env.stub :production?, true do
      assert_equal ['rubymem@ombulabs.com'], RubymemMailer.new_advisory(advisory.id).to
    end
  end
end
