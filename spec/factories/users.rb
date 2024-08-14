FactoryBot.define do
  factory :user do
    email { "user@example.com" }
    password { "password" }
    role { "user" } # Default role

    trait :admin do
      role { "admin" }
    end
  end
end
