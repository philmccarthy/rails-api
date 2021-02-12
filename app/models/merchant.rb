class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices

  def self.retrieve(results_per_page, page_number)
    if page_number == 1
      limit(results_per_page)
    else
      limit(results_per_page).offset(results_per_page * (page_number - 1))
    end
  end
end
