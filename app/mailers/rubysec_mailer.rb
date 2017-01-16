class RubysecMailer < ActionMailer::Base
  default from: "rubysec <noreply@appcanary.com>"
  layout 'mailer'

  def new_advisory(advisory_id)
    @advisory = RubysecAdvisory.find(advisory_id)

    if Rails.env.production?
      recipient = "info@rubysec.com"
    else
      recipient = "hello@appcanary.com"
    end

    mail(to: recipient, :subject => "New Rubysec submission!") do |format|
      format.text
    end
  end
end
