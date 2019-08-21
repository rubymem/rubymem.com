# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190605182812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "rubymem_advisories", force: :cascade do |t|
    t.string   "ident"
    t.string   "identifier"
    t.string   "gem"
    t.string   "url"
    t.string   "title"
    t.date     "date"
    t.text     "description"
    t.text     "unaffected_versions", default: [],                 array: true
    t.text     "patched_versions",    default: [],                 array: true
    t.hstore   "related",             default: {}
    t.text     "related_links",       default: [],                 array: true
    t.string   "submitter_email"
    t.boolean  "imported",            default: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["ident"], name: "index_rubymem_advisories_on_ident", using: :btree
    t.index ["identifier"], name: "index_rubymem_advisories_on_identifier", using: :btree
    t.index ["imported"], name: "index_rubymem_advisories_on_imported", using: :btree
  end

end
