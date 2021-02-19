# frozen_string_literal: true

class ItemsSoldSerializer
  include FastJsonapi::ObjectSerializer
  attribute :name

  attribute :count do |merchant|
    merchant.count.to_i
  end
end
