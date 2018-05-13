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

ActiveRecord::Schema.define(version: 20180501102836) do

  create_table "likes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.bigint "user_id"
    t.bigint "phrase_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phrase_id"], name: "index_likes_on_phrase_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.integer "x"
    t.integer "y"
    t.integer "length"
    t.bigint "phrase_id"
    t.index ["phrase_id"], name: "index_notes_on_phrase_id"
  end

  create_table "phrases", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "id_string"
    t.string "title"
    t.float "interval", limit: 24
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_string"], name: "index_phrases_on_id_string", unique: true
    t.index ["user_id"], name: "index_phrases_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4" do |t|
    t.string "id_string"
    t.string "display_name"
    t.string "photo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id_string"], name: "index_users_on_id_string", unique: true
  end

  add_foreign_key "likes", "phrases"
  add_foreign_key "likes", "users"
  add_foreign_key "notes", "phrases"
  add_foreign_key "phrases", "users"
end
