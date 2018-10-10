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

ActiveRecord::Schema.define(version: 2018_10_08_210241) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "addresses", force: :cascade do |t|
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "author_id"
    t.string "card_name"
    t.string "display_name"
    t.string "name"
    t.string "business_name"
    t.bigint "address_id"
    t.string "number"
    t.string "email"
    t.date "birth_date"
    t.string "twitter"
    t.string "linked_in"
    t.string "facebook"
    t.string "instagram"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address_id"], name: "index_cards_on_address_id"
    t.index ["author_id"], name: "index_cards_on_author_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "connections", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "contact_id"
    t.bigint "card_id"
    t.boolean "favorite", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_connections_on_card_id"
    t.index ["contact_id"], name: "index_connections_on_contact_id"
    t.index ["user_id"], name: "index_connections_on_user_id"
  end

  create_table "logs", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "contact_id"
    t.bigint "card_id"
    t.date "date"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["card_id"], name: "index_logs_on_card_id"
    t.index ["contact_id"], name: "index_logs_on_contact_id"
    t.index ["user_id"], name: "index_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.string "name"
    t.string "email"
    t.boolean "confirmed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "cards", "addresses"
  add_foreign_key "cards", "users"
  add_foreign_key "connections", "cards"
  add_foreign_key "connections", "users"
  add_foreign_key "logs", "cards"
  add_foreign_key "logs", "users"
end
