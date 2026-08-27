# == Schema Information
#
# Table name: rubymem_advisories
#
#  id                  :integer          not null, primary key
#  ident               :string
#  identifier          :string
#  gem                 :string
#  url                 :string
#  title               :string
#  date                :date
#  description         :text
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
#  index_rubymem_advisories_on_ident       (ident)
#  index_rubymem_advisories_on_identifier  (identifier)
#  index_rubymem_advisories_on_imported    (imported)
#

class RubymemAdvisory < ActiveRecord::Base
  has_secure_token :ident

  ATTRIBUTES = ["gem",
                "date",
                "url",
                "title",
                "description",
                "unaffected_versions",
                "patched_versions",
                "related",
                "related_links"]

  # Imported advisories come from the advisory database, where every file
  # carries these five. Submissions have to provide them too, plus a way to
  # reach the person reporting the leak.
  validates :gem, :url, :title, :date, :description, presence: true
  validates :submitter_email, presence: true, unless: :imported?

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
    # Submissions have no identifier until they are reviewed and imported, and
    # they are not published, so they fall back to the id.
    identifier&.split(".")&.first || id&.to_s
  end
end
