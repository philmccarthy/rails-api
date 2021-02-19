# frozen_string_literal: true

class UnshippedOrderSerializer
  include FastJsonapi::ObjectSerializer
  attribute :potential_revenue do |invoice|
    invoice.potential_revenue.to_f.round(2)
  end
end
