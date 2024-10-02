# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_09_26_003226) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "asset_incomes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "assets", force: :cascade do |t|
    t.integer "disclosure_id"
    t.string "asset"
    t.string "owner"
    t.integer "asset_value"
    t.string "income"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disclosure_id"], name: "index_assets_on_disclosure_id"
  end

  create_table "assets_income_types", force: :cascade do |t|
    t.integer "asset_id"
    t.integer "income_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "disclosures", force: :cascade do |t|
    t.integer "legislator_id", null: false
    t.integer "filing_type_id", null: false
    t.integer "state_id", null: false
    t.integer "district"
    t.integer "year"
    t.date "filing_date"
    t.string "document_id"
    t.string "document_text"
    t.boolean "image_pdf"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "json_text"
    t.boolean "gpt_test"
    t.index ["filing_type_id"], name: "index_disclosures_on_filing_type_id"
    t.index ["legislator_id"], name: "index_disclosures_on_representative_id"
    t.index ["state_id"], name: "index_disclosures_on_state_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "external_id"
    t.integer "disclosure_id"
    t.string "document_text"
    t.jsonb "document_json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "filing_types", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "income_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "legislators", force: :cascade do |t|
    t.string "bioguide_id"
    t.string "prefix"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "suffix"
    t.integer "birth_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parties", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "party_affiliations", force: :cascade do |t|
    t.integer "legislator_id"
    t.integer "party_id"
    t.integer "start_year"
    t.integer "end_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "terms", force: :cascade do |t|
    t.integer "legislator_id"
    t.string "chamber"
    t.integer "congress"
    t.integer "state_id"
    t.integer "district"
    t.integer "start_year"
    t.integer "end_year"
    t.string "member_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "disclosure_id"
    t.date "date"
    t.string "asset"
    t.integer "owner"
    t.integer "amount"
    t.integer "transaction_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["disclosure_id"], name: "index_transactions_on_disclosure_id"
  end

end
