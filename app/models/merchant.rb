class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices

  class << self
    def search_by_name(name)
      where('lower(name) LIKE ?', "%#{name.downcase}%").
      order(:name)
    end
  end
end
