class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices

  class << self
    # def find_all(name)
    #   return [] if name.blank?
    #   where('lower(name) LIKE ?', "%#{name.downcase}%").
    #   order(:name)
    # end
  end
end
