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

ActiveRecord::Schema[8.1].define(version: 2026_02_26_203219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "calendar_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.string "day_type", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_calendar_types_on_date", unique: true
  end

  create_table "change_requests", force: :cascade do |t|
    t.text "admin_response"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "request_details", null: false
    t.bigint "reservation_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_change_requests_on_customer_id"
    t.index ["reservation_id"], name: "index_change_requests_on_reservation_id"
    t.index ["status"], name: "index_change_requests_on_status"
  end

  create_table "customer_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_sessions_on_customer_id"
    t.index ["token_digest"], name: "index_customer_sessions_on_token_digest", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.string "company_name", null: false
    t.string "contact_name", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "notes"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email", unique: true
  end

  create_table "email_templates", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "facility_id", null: false
    t.string "subject", null: false
    t.string "template_type", default: "quote", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id", "template_type"], name: "index_email_templates_on_facility_id_and_template_type", unique: true
  end

  create_table "facilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "email_signature"
    t.string "name", null: false
    t.string "sender_domain", null: false
    t.string "sender_email", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_facilities_on_name", unique: true
  end

  create_table "inquiries", force: :cascade do |t|
    t.boolean "accommodation", default: false
    t.boolean "breakfast", default: false
    t.string "company_name", null: false
    t.boolean "conference_room", default: false
    t.string "contact_name", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id"
    t.date "desired_date", null: false
    t.date "desired_end_date", null: false
    t.boolean "dinner", default: false
    t.string "email", null: false
    t.bigint "facility_id", null: false
    t.boolean "lunch", default: false
    t.integer "num_people", null: false
    t.integer "total_amount"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_inquiries_on_customer_id"
    t.index ["facility_id"], name: "index_inquiries_on_facility_id"
  end

  create_table "price_masters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "day_type", null: false
    t.bigint "facility_id", null: false
    t.string "item_type", null: false
    t.integer "unit_price", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id", "item_type", "day_type"], name: "index_price_masters_on_facility_id_and_item_type_and_day_type", unique: true
    t.index ["facility_id"], name: "index_price_masters_on_facility_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "inquiry_id", null: false
    t.binary "pdf_data"
    t.datetime "sent_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["inquiry_id"], name: "index_quotes_on_inquiry_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.text "admin_notes"
    t.datetime "cancelled_at"
    t.date "check_in_date", null: false
    t.date "check_out_date"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.bigint "facility_id", null: false
    t.bigint "inquiry_id", null: false
    t.integer "num_people", null: false
    t.string "status", default: "pending_confirmation", null: false
    t.integer "total_amount"
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_reservations_on_customer_id"
    t.index ["facility_id"], name: "index_reservations_on_facility_id"
    t.index ["inquiry_id"], name: "index_reservations_on_inquiry_id"
    t.index ["status"], name: "index_reservations_on_status"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.string "role", default: "staff", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "change_requests", "customers"
  add_foreign_key "change_requests", "reservations"
  add_foreign_key "customer_sessions", "customers"
  add_foreign_key "email_templates", "facilities"
  add_foreign_key "inquiries", "customers"
  add_foreign_key "inquiries", "facilities"
  add_foreign_key "price_masters", "facilities"
  add_foreign_key "quotes", "inquiries"
  add_foreign_key "reservations", "customers"
  add_foreign_key "reservations", "facilities"
  add_foreign_key "reservations", "inquiries"
  add_foreign_key "sessions", "users"
end
