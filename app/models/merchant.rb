class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices

  class << self
    def most_revenue(quantity)
      Merchant.joins(invoices: [:transactions, :invoice_items]).
      select('merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue').
      where(transactions: { result: 'success' }, invoices: { status: 'shipped' }).
      group(:id).
      order(revenue: :desc).
      limit(quantity)
    end

    def most_items_sold(quantity)
      Merchant.joins(invoices: [:transactions, :invoice_items]).
      select('merchants.*, SUM(invoice_items.quantity) AS count').
      where(transactions: { result: 'success' }, invoices: { status: 'shipped' }).
      group('merchants.id').
      order('count desc').
      limit(quantity)
    end

    def total_revenue(merchant_id)
      Merchant.joins(invoices: [:transactions, :invoice_items]).
      select('merchants.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue').
      where(
        merchants: { id: merchant_id },
        transactions: {result: 'success' },
        invoices: { status: 'shipped' }).
      group(:id).
      first!
    end
  end
end
