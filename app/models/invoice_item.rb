class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :transactions, through: :invoice
  has_one :merchant, through: :item

  after_destroy :destroy_empty_invoice

  def destroy_empty_invoice
    invoice.destroy if !invoice.invoice_items.any?
  end
end


# Order with highest potential revenue
#   InvoiceItem.select('quantity * unit_price AS potential_revenue').where(invoice_id: 4844)