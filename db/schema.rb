# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160508192426) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "rewards", force: :cascade do |t|
    t.integer  "sprint_id"
    t.string   "type"
    t.integer  "mana"
    t.integer  "crystal"
    t.integer  "energy"
    t.integer  "amount"
    t.integer  "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "rewards", ["sprint_id"], name: "index_rewards_on_sprint_id", using: :btree

  create_table "runes", force: :cascade do |t|
    t.integer  "reward_id"
    t.integer  "grade"
    t.integer  "sell_value"
    t.integer  "set"
    t.decimal  "efficiency", precision: 5, scale: 2, default: 0.0
    t.integer  "slot"
    t.integer  "rarity"
    t.string   "primary"
    t.string   "innate"
    t.string   "secondary1"
    t.string   "secondary2"
    t.string   "secondary3"
    t.string   "secondary4"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "runes", ["reward_id"], name: "index_runes_on_reward_id", using: :btree

  create_table "scenarios", force: :cascade do |t|
    t.string   "name"
    t.integer  "stage"
    t.integer  "level",      default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "sprints", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "scenario_id"
    t.string   "digest",      limit: 32
    t.boolean  "win"
    t.integer  "time_taken"
    t.datetime "started_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "sprints", ["scenario_id"], name: "index_sprints_on_scenario_id", using: :btree
  add_index "sprints", ["user_id"], name: "index_sprints_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "rewards", "sprints"
  add_foreign_key "runes", "rewards"
  add_foreign_key "sprints", "scenarios"
  add_foreign_key "sprints", "users"
end
