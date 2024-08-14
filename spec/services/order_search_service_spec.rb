require 'rails_helper'

RSpec.describe OrderSearchService do
  let!(:product) { Product.create!(name: "Prod A", stock: 10, price: 10) }
  let!(:second_product) { Product.create!(name: "Prod B", stock: 15, price: 15) }
  let!(:order1) { create(:order, product: product, created_at: "2024-01-01") }
  let!(:order2) { create(:order, :awaiting_pickup, product: second_product, customer_name: "Jane Smith", created_at: "2024-02-01") }
  let!(:order3) { create(:order, :awaiting_pickup, product: second_product, customer_name: "Jane Perez", created_at: "2024-03-01") }

  it "filters by product id" do
    result = described_class.new(product_id: product.id).call
    expect(result).to include(order1)
    expect(result).not_to include(order2)
  end

  it "filters by customer_name" do
    result = described_class.new(customer_name: "Jane").call
    expect(result).to include(order2)
    expect(result).not_to include(order1)
  end

  it "filters by status" do
    result = described_class.new(status: "processing").call
    expect(result).to include(order1)
    expect(result).not_to include(order2)
  end

  it "filters by created_at" do
    result = described_class.new(created_at: "2024-01-01").call
    expect(result).to include(order1)
    expect(result).not_to include(order2)
  end

  it "filters by status and product id" do
    result = described_class.new(status: "awaiting_pickup", product_id: second_product.id).call
    expect(result).to include(order2)
    expect(result).to include(order3)
    expect(result).not_to include(order1)
  end

  it "filters by status, product id and customer name" do
    result = described_class.new(status: "awaiting_pickup", product_id: second_product.id, customer_name: "Perez").call
    expect(result).to include(order3)
    expect(result).not_to include(order1)
    expect(result).not_to include(order2)
  end


end
