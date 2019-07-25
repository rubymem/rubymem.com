class RubymemMailer < ActionMailer::Base
  default from: "rubymem <noreply@appcanary.com>"
  layout 'mailer'

  def new_advisory(advisory_id)
    @advisory = RubymemAdvisory.find(advisory_id)

    if Rails.env.production?
      recipient = "info@rubymem.com"
    else
      recipient = "hello@appcanary.com"
    end

    mail(to: recipient, :subject => "New Rubymem submission!") do |format|
      format.text
    end
  end
end
