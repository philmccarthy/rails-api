class MerchantRevenueSerializer
  include FastJsonapi::ObjectSerializer
  attribute :revenue do |merchant|
    merchant.revenue.to_f.round(2)
  end
end
