require "rails_helper"

RSpec.describe Order do
  subject { described_class.new(
    product: Product.new,
    customer_name: "Jorge")
  }

  it "is not valid without a product" do
    subject.product = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a customer name" do
    subject.customer_name = nil
    expect(subject).to_not be_valid
  end

  it "is not valid without a status" do
    subject.status = nil
    expect(subject).to_not be_valid
  end

  it "is valid when it has product, customer name and status" do
    expect(subject).to be_valid
  end

  it "is created with processing status as default" do
    expect(subject.status).to eq("processing")
  end
end
