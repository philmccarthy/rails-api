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
      parse_query(params)
      if price_range_query?
        find_item_where_price_within_range
      elsif min_price_query?
        find_item_where_price_above_minimum
      elsif max_price_query?
        find_item_where_price_under_maximum
      else
        find_item_by_name
      end
    end

    private

    def find_item_where_price_within_range
      order(:name).
      find_by('unit_price >= ? AND unit_price <= ?',
        @@min_price_query.to_f, @@max_price_query.to_f)
    end

    def find_item_where_price_above_minimum
      order(:name).
      find_by('unit_price >= ?', @@min_price_query.to_f)
    end

    def find_item_where_price_under_maximum
      order(:name).
      find_by('unit_price <= ?', @@max_price_query.to_f)
    end

    def find_item_by_name
      return if @@name_query.blank?
      name_match = find_all(@@name_query).first
      return name_match if name_match.present?
      search_description(@@name_query)
    end

    def search_description(string)
      order(:name).
      find_by('lower(description) LIKE ?',
      "%#{string.downcase}%")
    end

    def parse_query(params)
      @@name_query, @@min_price_query, @@max_price_query =
      [params[:name], params[:min_price], params[:max_price]]
    end

    def price_range_query?
      @@min_price_query && @@max_price_query
    end

    def min_price_query?
      @@min_price_query.present?
    end

    def max_price_query?
      @@max_price_query.present?
    end
  end
end
