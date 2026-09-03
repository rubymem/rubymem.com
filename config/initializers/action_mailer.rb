# Review apps and staging run with RAILS_ENV=production, so Rails.env cannot
# tell them apart from the real thing. DISABLE_MAIL_DELIVERY is what draws the
# line: app.json sets it for every review app, and production does not set it,
# so production keeps delivering without needing any new variable of its own.
# Mail is still rendered and logged when it is off, only the SMTP call is
# skipped, which is also the answer when there are no SendGrid credentials for
# an environment.
#
# The variable is named for the exception so that leaving it unset delivers.
deliver_mail = ENV['DISABLE_MAIL_DELIVERY'].blank?

Rails.application.config.action_mailer.perform_deliveries = deliver_mail
Rails.application.config.action_mailer.default_options = {from: "info@rubymem.com"}

if deliver_mail
  Rails.application.config.action_mailer.smtp_settings = {
    user_name: ENV["SENDGRID_USERNAME"],
    password: ENV["SENDGRID_PASSWORD"],
    domain: "rubymem.com",
    address: "smtp.sendgrid.net",
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }
end
