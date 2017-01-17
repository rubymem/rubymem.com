Rails.application.config.action_mailer.perform_deliveries = true
Rails.application.config.action_mailer.default_options = {from: 'info@rubysec.com'}
Rails.application.config.action_mailer.smtp_settings = {
  :address   => "smtp.mandrillapp.com",
  :port      => 587, # ports 587 and 2525 are also supported with STARTTLS
  :enable_starttls_auto => true, # detects and uses STARTTLS
  :user_name => Rails.configuration.mandrill.user_name,
  :password => Rails.configuration.mandrill.api_key,
  :authentication => 'login',
  :domain => "rubysec.com"
}

