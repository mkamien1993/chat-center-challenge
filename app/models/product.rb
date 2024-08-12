class Product < ActiveRecord::Base
  STATUS = ['processing'].concat(Fedex::Shipment::STATUS).freeze
end
