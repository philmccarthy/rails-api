class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  
  enum status: { pending: 0, packed: 1, shipped: 2 }
end
