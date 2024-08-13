class Order < ApplicationRecord
  belongs_to :product
  validates :customer_name, :status, presence: true

  enum :status, { processing: 0, awaiting_pickup: 1, in_transit: 2, out_for_delivery: 3, delivered: 4 }
end
