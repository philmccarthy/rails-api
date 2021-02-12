class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_one :merchant, through: :item
end


# Order with highest potential revenue
#   InvoiceItem.select('quantity * unit_price AS potential_revenue').where(invoice_id: 4844)