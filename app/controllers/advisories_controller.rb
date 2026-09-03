class AdvisoriesController < ApplicationController
  def index
    @advisories = RubymemAdvisory.imported.recent.paginate(:page => params[:page])
  end

  def show
    @advisory = RubymemAdvisory.where(:identifier => params[:id]).take!
  end

  def new
    @advisory = RubymemAdvisory.new
    assign_presenter
  end

  def preview
    @advisory = RubymemAdvisory.new(processed_params)

    if @advisory.valid?
      prepare_preview
    else
      assign_presenter
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @advisory = RubymemAdvisory.new(processed_params)

    if @advisory.save
      RubymemMailer.new_advisory(@advisory.id).deliver_now
      redirect_to thanks_advisories_path
    else
      prepare_preview
      render :preview, status: :unprocessable_entity
    end
  end

  def thanks
  end

  private

  # The form is driven by the presenter, every action that renders it needs one.
  def assign_presenter
    @presenter = AdvisoryPresenter.new(@advisory)
  end

  # The preview page also needs the YAML and the button that submits it.
  def prepare_preview
    assign_presenter
    @preview = @advisory.generate_yaml
    @submit = true
  end

  def advisory_params
    params.require(:advisory_presenter)
      .permit(:gem, :framework, :platform,
              :cve, :url, :title,
              :date, :description, :cvss_v2,
              :cvss_v3, :unaffected_versions,
              :patched_versions, :related_links, :submitter_email)
  end

  def processed_params
    advisory_params.tap do |hsh|
      ["unaffected_versions", "patched_versions", "related_links"].each do |k|
        hsh[k] = hsh[k].try(:lines).try(:map, &:strip)
      end
    end
  end

end
