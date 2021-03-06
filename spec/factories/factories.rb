FactoryBot.define do
  factory :item do
    name { Faker::Food.spice }
    description { Faker::Food.description }
    unit_price { Faker::Number.decimal(l_digits: 2) }
    merchant_id { create(:merchant).id }

    factory :item_with_invoices do
      transient do
        invoice_count { 5 }
      end

      after(:create) do |item, evaluator|
        create_list(:invoice_item, evaluator.invoice_count, item: item)
      end
    end
  end

  factory :merchant do
    name { Faker::Company.name }

    factory :merchant_with_items do
      transient do
        items_count { 5 }
      end

      after(:create) do |merchant, evaluator|
        create_list(:item_with_invoices, evaluator.items_count, merchant: merchant)
      end
    end
  end

  factory :customer do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end

  factory :invoice_item do
    item { create(:item) }
    invoice { create(:invoice) }
    quantity { Faker::Number.within(range: 1..10) }
    unit_price { Faker::Number.decimal(l_digits: 2) }
  end

  factory :invoice do
    customer { create(:customer) }
    merchant { create(:merchant) }
    status { 'shipped' }
  end

  factory :transaction do
    invoice { nil }
    credit_card_number { "1234123412341234" }
    credit_card_expiration_date { "01/21" }
    result { 'success' }
  end
end
