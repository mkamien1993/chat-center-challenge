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

ActiveRecord::Schema[7.1].define(version: 2024_08_14_132730) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", force: :cascade do |t|
    t.bigint "product_id"
    t.string "customer_name"
    t.string "adress"
    t.string "zip_code"
    t.string "shipping_method"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "status", default: 0
    t.integer "fedex_id"
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["customer_name"], name: "index_orders_on_customer_name"
    t.index ["product_id", "status"], name: "index_orders_on_product_id_and_status"
    t.index ["product_id"], name: "index_orders_on_product_id"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.decimal "price", precision: 8, scale: 2
    t.integer "stock"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "orders", "products"
end
