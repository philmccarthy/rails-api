class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  
  validates :merchant, presence: true
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, numericality: { greater_than: 0 }
end
