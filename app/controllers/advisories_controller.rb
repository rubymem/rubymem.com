class AdvisoriesController < ApplicationController
  def index
    @advisories = RubysecAdvisory.imported.recent.paginate(:page => params[:page])
  end

  def show
    @advisory = RubysecAdvisory.where(:identifier => id_with_yml(params[:id])).take!
  end

  def preview
    @advisory = RubysecAdvisory.new(processed_params)
    @presenter = AdvisoryPresenter.new(@advisory)
    @preview = @advisory.generate_yaml
    @submit = true
  end

  def create
    @advisory = RubysecAdvisory.new(processed_params)

    unless @advisory.save
      @submit = true
      render :preview
    end
    RubysecMailer.new_advisory(@advisory.id).deliver_now
  end

  def advisory_params
    params.require(:advisory_presenter).
      permit(:gem, :framework, :platform, 
             :cve, :url, :title, 
             :date, :description, :cvss_v2, 
             :cvss_v3, :unaffected_versions, 
             :patched_versions, :related_links, :submitter_email)
  end

  def id_with_yml(str)
    "#{str}.yml"
  end

  def processed_params
    advisory_params.tap do |hsh|
      ["unaffected_versions", "patched_versions", "related_links"].each do |k|
        hsh[k] = hsh[k].try(:lines).try(:map, &:strip)
      end
    end
  end

end
