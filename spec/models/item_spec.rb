require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of :merchant }
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'class methods' do
    it '::find_item_where_price_within_range' do
    end

    it '::find_item_where_price_above_minimum' do
    end

    it '::find_item_where_price_under_maximum' do
    end

    it '::find_item_by_name' do
    end

    it '::search_description' do
    end

    it '::parse_query' do
    end

    it '::price_range_query?' do
    end

    it '::min_price_query?' do
    end

    it '::max_price_query?' do
    end
  end
end
