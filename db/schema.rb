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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131222075823) do

  create_table "brands", :force => true do |t|
    t.text "name"
  end

  create_table "recipients", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "classname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "vehicles", :force => true do |t|
    t.text     "title"
    t.text     "url"
    t.integer  "model"
    t.text     "mileage"
    t.text     "price"
    t.text     "contact_number"
    t.text     "vtype"
    t.text     "description"
    t.text     "others"
    t.integer  "brand_id"
    t.datetime "notified_at"
    t.datetime "viewed_at"
    t.boolean  "favorite"
    t.text     "comments"
    t.string   "location"
    t.string   "username"
    t.datetime "timestamp"
    t.string   "class_name"
    t.string   "trim_name"
    t.string   "outside_color"
    t.string   "gear"
    t.integer  "cylinders"
    t.string   "inside_color"
    t.string   "inside_type"
    t.boolean  "sunroof"
    t.boolean  "sensors"
    t.boolean  "camera"
    t.boolean  "dvd"
    t.boolean  "cd"
    t.boolean  "bluetooth"
    t.boolean  "gps"
    t.string   "contact_number2"
    t.integer  "source_id"
    t.integer  "sid_i"
    t.string   "sid_s"
  end

  add_index "vehicles", ["sid_i"], :name => "index_vehicles_on_sid_i"
  add_index "vehicles", ["sid_s"], :name => "index_vehicles_on_sid_s"
  add_index "vehicles", ["source_id"], :name => "index_vehicles_on_source_id"
  add_index "vehicles", ["url"], :name => "index_vehicles_on_url", :unique => true

end
