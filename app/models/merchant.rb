class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
has_many :customers, through: :invoices

  class << self
    def most_revenue(quantity)
      require 'pry'; binding.pry
    end
  end
end
