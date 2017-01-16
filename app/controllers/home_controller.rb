class HomeController < ApplicationController
  def preview
    @advisory = RubysecAdvisory.new(advisory_params)
    @preview = @advisory.generate_yaml
    @submit = true
  end

  def create
    @advisory = RubysecAdvisory.new(advisory_params)

    unless @advisory.save
      @submit = true
      render :preview
    end
    RubysecMailer.new_advisory(@advisory.id).deliver_now
  end

  def advisory_params
    params.require(:rubysec_advisory).
      permit(:gem, :framework, :platform, 
             :cve, :url, :title, 
             :date, :description, :cvss_v2, 
             :cvss_v3, :unaffected_versions, 
             :patched_versions, :related, :submitter_email)
  end
end
