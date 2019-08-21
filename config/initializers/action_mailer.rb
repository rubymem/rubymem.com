Rails.application.config.action_mailer.perform_deliveries = true
Rails.application.config.action_mailer.default_options = {from: "info@rubymem.com"}
Rails.application.config.action_mailer.smtp_settings = {
  user_name: ENV["SENDGRID_USERNAME"],
  password: ENV["SENDGRID_PASSWORD"],
  domain: "rubymem.com",
  address: "smtp.sendgrid.net",
  port: 587,
  authentication: :plain,
  enable_starttls_auto: true
}

