class AdvisoryPresenter
  extend ActiveModel::Naming
  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  
  delegate :gem, :date, :url, :cve, :title, :description, :cvss_v2, :cvss_v3, :submitter_email, to: :advisory

  attr_reader :advisory

  def initialize(advisory)
    @advisory = advisory
  end

  def unaffected_versions
    @advisory.unaffected_versions.join("\n")
  end

  def patched_versions
    @advisory.patched_versions.join("\n")
  end

  def related_links
    @advisory.related_links.join("\n")
  end

end
