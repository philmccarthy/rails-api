# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items

  class << self
    def unshipped_potential_revenue(quantity)
      quantity = 10 if quantity.nil?
      Invoice.joins(:invoice_items)
             .where(status: 'packaged')
             .select('invoices.*, (invoice_items.quantity * invoice_items.unit_price) AS potential_revenue')
    end
  end
end
