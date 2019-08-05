class ApplicationMailer < ActionMailer::Base
  default from: 'info@rubymem.com'
  layout 'mailer'

  def test_this
    mail(to: "phillmv@appcanary.com", subject: "yep we send mail", body: "holla", content_type: "text/plain")
  end
end
