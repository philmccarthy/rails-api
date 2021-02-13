FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }

    factory :merchant_with_items do
      transient do
        items_count { 10 }
      end

      after(:create) do |merchant, evaluator|
        create_list(:item, evaluator.items_count, merchant: merchant)
      end
    end
  end

  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :item do
    name { Faker::Food.spice }
    description { Faker::Food.description }
    unit_price { Faker::Number.decimal(l_digits: 2) }
    merchant
  end

  # factory :invoice do
  #   status { [:pending ] }
  # end
end
