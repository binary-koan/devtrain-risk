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

ActiveRecord::Schema.define(version: 20151214015533) do

  create_table "action_adds", force: :cascade do |t|
    t.integer  "territory_id", null: false
    t.integer  "units",        null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "action_kills", force: :cascade do |t|
    t.integer  "territory_id",      null: false
    t.integer  "units",             null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "territory_from_id", null: false
  end

  create_table "action_moves", force: :cascade do |t|
    t.integer  "territory_from_id", null: false
    t.integer  "territory_to_id",   null: false
    t.integer  "units"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "actions", force: :cascade do |t|
    t.integer  "event_id",           null: false
    t.integer  "territory_id",       null: false
    t.integer  "action_type",        null: false
    t.integer  "territory_owner_id", null: false
    t.integer  "units_difference",   null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "actions", ["event_id"], name: "index_actions_on_event_id"

  create_table "continents", force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.string   "color",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer  "action_id"
    t.string   "action_type"
    t.integer  "player_id",   null: false
    t.string   "event_type",  null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "events", ["player_id"], name: "index_events_on_player_id"

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.integer  "game_id",    null: false
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "territories", force: :cascade do |t|
    t.integer  "x",            null: false
    t.integer  "y",            null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name",         null: false
    t.integer  "continent_id"
  end

  add_index "territories", ["continent_id"], name: "index_territories_on_continent_id"

  create_table "territory_links", force: :cascade do |t|
    t.integer  "from_territory_id", null: false
    t.integer  "to_territory_id",   null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
