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

ActiveRecord::Schema.define(:version => 20131210104524) do

  create_table "brands", :force => true do |t|
    t.text "name"
  end

  create_table "recipients", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.string   "[:location, :username]"
    t.string   "location"
    t.string   "username"
    t.datetime "timestamp"
  end

  add_index "vehicles", ["url"], :name => "index_vehicles_on_url", :unique => true

end
