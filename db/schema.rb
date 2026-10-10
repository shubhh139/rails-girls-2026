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

ActiveRecord::Schema[8.1].define(version: 2026_10_10_101329) do
  create_table "blood_requests", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "patient_name", null: false
    t.string "blood_group", null: false
    t.integer "units_needed", default: 1, null: false
    t.string "hospital", null: false
    t.string "city", null: false
    t.date "needed_by", null: false
    t.string "contact_phone", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blood_group", "city"], name: "index_blood_requests_on_blood_group_and_city"
    t.index ["user_id"], name: "index_blood_requests_on_user_id"
  end

  create_table "donor_profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "blood_group", null: false
    t.string "city", null: false
    t.string "phone", null: false
    t.boolean "available", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blood_group", "city"], name: "index_donor_profiles_on_blood_group_and_city"
    t.index ["user_id"], name: "index_donor_profiles_on_user_id", unique: true
  end

  create_table "responses", force: :cascade do |t|
    t.integer "blood_request_id", null: false
    t.integer "donor_id", null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blood_request_id", "donor_id"], name: "index_responses_on_blood_request_id_and_donor_id", unique: true
    t.index ["blood_request_id"], name: "index_responses_on_blood_request_id"
    t.index ["donor_id"], name: "index_responses_on_donor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "blood_requests", "users"
  add_foreign_key "donor_profiles", "users"
  add_foreign_key "responses", "blood_requests"
  add_foreign_key "responses", "users", column: "donor_id"
end
