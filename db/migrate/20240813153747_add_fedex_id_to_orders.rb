class AddFedexIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :fedex_id, :integer
  end
end
