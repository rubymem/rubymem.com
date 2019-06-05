class CreateRubymemLeakyGems < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'hstore'

    create_table :rubymem_leaky_gems do |t|
      t.string :ident, index: true
      t.string :identifier, index: true
      t.string :gem
      t.string :url
      t.string :title
      t.date :date
      t.text :description
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
