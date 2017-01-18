class CreateRubysecAdvisories < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    
    create_table :rubysec_advisories do |t|
      t.string :ident, index: true
      t.string :identifier, index: true
      t.string :gem
      t.string :cve
      t.string :osvdb
      t.string :url
      t.string :title
      t.date :date
      t.text :description
      t.string :cvss_v2
      t.string :cvss_v3
      t.text :unaffected_versions, array: true, :default => []
      t.text :patched_versions, array: true, :default => []
      t.hstore :related, :default => {}
      t.text :related_links, array: true, :default => []
      t.string :submitter_email
      t.boolean :imported, default: false, index: true
      t.timestamps null: false
    end
  end
end
