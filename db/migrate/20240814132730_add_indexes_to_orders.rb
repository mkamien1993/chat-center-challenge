class AddIndexesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_index :orders, :customer_name
    add_index :orders, :status
    add_index :orders, :created_at

    add_index :orders, [:product_id, :status]
  end
end
