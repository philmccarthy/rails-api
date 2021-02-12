FactoryBot.define do
  factory :merchant do
    name { Faker::Company.name }
  end

  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :item do
    name { Faker::Food.spice }
    description { Faker::Food.description }
    unit_price { Faker::Number.decimal(l_digits: 2) }
  end

  # factory :invoice do
  #   status { [:pending ] }
  # end
end
