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
#  unaffected_versions :text
#  patched_versions    :text
#  related             :text
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
                "related"]

  def generate_yaml
    self.attributes.slice(*ATTRIBUTES).tap do |hsh|
      ["unaffected_versions", "patched_versions", "related"].each do |k|
        hsh[k] = hsh[k].lines.map(&:strip)
      end
    end.compact.to_yaml
  end

  def relevant_attributes
    self.attributes.except("id", "ident", "updated_at", "created_at")
  end
end
