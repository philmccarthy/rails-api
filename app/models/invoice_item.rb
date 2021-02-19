# frozen_string_literal: true

class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_many :transactions, through: :invoice
  has_one :merchant, through: :item

  after_destroy :destroy_empty_invoice

  def destroy_empty_invoice
    invoice.destroy if invoice.invoice_items.none?
  end
end
