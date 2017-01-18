# == Schema Information
#
# Table name: rubysec_advisories
#
#  id                  :integer          not null, primary key
#  ident               :string
#  identifier          :string
#  gem                 :string
#  cve                 :string
#  osvdb               :string
#  url                 :string
#  title               :string
#  date                :date
#  description         :text
#  cvss_v2             :string
#  cvss_v3             :string
#  unaffected_versions :text             default("{}"), is an Array
#  patched_versions    :text             default("{}"), is an Array
#  related             :hstore           default("")
#  related_links       :text             default("{}"), is an Array
#  submitter_email     :string
#  imported            :boolean          default("false")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_rubysec_advisories_on_ident       (ident)
#  index_rubysec_advisories_on_identifier  (identifier)
#  index_rubysec_advisories_on_imported    (imported)
#

class RubysecAdvisory < ActiveRecord::Base
  has_secure_token :ident

  ATTRIBUTES = ["gem",
                "date",
                "url",
                "cve",
                "title",
                "description",
                "cvss_v2",
                "cvss_v3",
                "unaffected_versions",
                "patched_versions",
                "related",
                "related_links"]

  scope :recent, -> { order(date: :desc) }
  scope :imported, -> { where(imported: true) }

  def generate_yaml
    self.attributes.slice(*ATTRIBUTES)
      .reject { |k,v| v.blank? }.to_yaml
  end

  def relevant_attributes
    self.attributes.except("id", "ident", "updated_at", "created_at")
  end

  def to_param
    identifier.split(".")[0]
  end
end
