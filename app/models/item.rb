class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices
  
  validates :merchant, presence: true
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, numericality: { greater_than: 0 }
  class << self
    def find_one(params)
      if params[:name] && params[:min_price] || params[:max_price]
        # error?
      elsif params[:min_price] && params[:max_price]
        # method to return first match by alpha order
      elsif params[:min_price]
        # method to eturn first match by alpha order
      elsif params[:max_price]
        # method to return first match by alpha order
      else params[:name]
        name_match = find_all(params[:name]).first
        return name_match if name_match.present?
        search_description(params[:name])
      end
    end

    def search_description(string)
      where('lower(description) LIKE ?', "%#{string.downcase}%").
      order(:name).
      first
    end
  end
end
