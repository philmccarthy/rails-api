class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices

  class << self
    def most_revenue(quantity)
      Merchant.select(
        'merchants.*, 
        SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue').
        joins(invoices: [:transactions, :invoice_items]).
        where(transactions: { result: 'success' }, invoices: { status: 'shipped' }).
        group(:id).
        order(revenue: :desc).
        limit(quantity)
    end
  end
end
