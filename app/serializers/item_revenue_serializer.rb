class ItemRevenueSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :description
  attribute :unit_price do |item| 
    item.unit_price.to_f
  end

  attribute :merchant_id do |item|
    item.merchant_id.to_i
  end

  attribute :revenue do |item| 
    item.revenue.to_f.round(2)
  end
end
