# Rendered at http://localhost:3000/rails/mailers/rubymem_mailer/new_advisory
# Needs at least one advisory in the development database; `rake rubymem:import`
# fills it.
class RubymemMailerPreview < ActionMailer::Preview
  def new_advisory
    RubymemMailer.new_advisory(RubymemAdvisory.first!.id)
  end
end
