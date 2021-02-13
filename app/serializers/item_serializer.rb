class ItemSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :description
  attribute :unit_price do |item|
    item.unit_price.to_f
  end
  attribute :merchant_id do |item|
    item.id.to_f
  end
end
