json.array!(@orders) do |order|
  json.extract! order, :id, product_id, :customer_name
  json.url order_url(order, format: :json)
end
