class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items
  has_many :items, through: :invoice_items
  
  enum status: { pending: 0, packaged: 1, shipped: 2, returned: 3 }
end
