class RubymemMailer < ActionMailer::Base
  default from: "rubymem <noreply@rubymem.com>"
  layout 'mailer'

  def new_advisory(advisory_id)
    @advisory = RubymemAdvisory.find(advisory_id)

    if Rails.env.production?
      recipient = "rubymem@ombulabs.com"
    else
      recipient = "hello@ombulabs.com"
    end

    mail(to: recipient, :subject => "New Rubymem submission!") do |format|
      format.text
    end
  end
end
