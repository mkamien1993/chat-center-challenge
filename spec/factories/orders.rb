FactoryBot.define do
  factory :order do
    customer_name { "John Doe" }
    product { Product.new }
    status { :processing }
    fedex_id { nil }  # Default to nil; can be overridden when needed
    created_at { Time.now }
    updated_at { Time.now }

    trait :with_fedex_id do
      fedex_id { rand(1000..9999) }  # Generate a random fedex_id
    end

    trait :awaiting_pickup do
      status { :awaiting_pickup }
    end
  end
end
