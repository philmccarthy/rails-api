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

    it '::top_ten_by_revenue' do
      merchant_1 = create(:merchant_with_items)
      invoice_1 = create(:invoice, merchant: merchant_1, status: 'shipped')
      create(:invoice_item, item: merchant_1.items.first, invoice: invoice_1, quantity: 10, unit_price: 10.00)
      create(:transaction, invoice: invoice_1)
      
      merchant_2 = create(:merchant_with_items)
      invoice_2 = create(:invoice, merchant: merchant_2, status: 'shipped')
      # Invoice 3 should not count toward revenue because invoice status is returned
      invoice_3 = create(:invoice, merchant: merchant_2, status: 'returned')
      invoice_4 = create(:invoice, merchant: merchant_2, status: 'shipped')
      create(:invoice_item, item: merchant_2.items.first, invoice: invoice_2, quantity: 20, unit_price: 10.00)
      create(:invoice_item, item: merchant_2.items.second, invoice: invoice_2, quantity: 1, unit_price: 100.00)
      create(:invoice_item, item: merchant_2.items.third, invoice: invoice_3, quantity: 1, unit_price: 100.00)
      create(:invoice_item, item: merchant_2.items.fourth, invoice: invoice_4, quantity: 1, unit_price: 100.00)
      create(:transaction, invoice: invoice_2)
      create(:transaction, invoice: invoice_3)
      create(:transaction, invoice: invoice_4, result: 'failed')
      # Invoice 4 should not count toward revenue because transaction result failed

      items_with_most_revenue = Item.most_revenue(3)

      expect(items_with_most_revenue.first.revenue).to eq(200)
      expect(items_with_most_revenue.second.revenue).to eq(100)
      expect(items_with_most_revenue.third.revenue).to eq(100)

      result_without_quantity_argument = Item.most_revenue(nil)
      
      expect(result_without_quantity_argument.first.revenue).to eq(200)
      expect(result_without_quantity_argument.second.revenue).to eq(100)
      expect(result_without_quantity_argument.third.revenue).to eq(100)
    end

    it '::find_one' do
      create(:item, name: 'Maple Syrup', unit_price: 5.00)
      create(:item, name: 'Waffles', unit_price: 7.00)
      create(:item, name: 'Chicken Cutlet', description: 'It is different.', unit_price: 2.50)

      search_params = { name: 'syRuP' }
      item_by_name = Item.find_one(search_params)
      expect(item_by_name.name).to eq('Maple Syrup')

      search_params = { name: 'diff' }
      item_by_description = Item.find_one(search_params)
      expect(item_by_description.name).to eq('Chicken Cutlet')
      
      search_params = { min_price: 6.00 }
      item_by_min_price = Item.find_one(search_params)
      expect(item_by_min_price.name).to eq('Waffles')
      
      
      search_params = { max_price: 5.00 }
      item_by_min_price = Item.find_one(search_params)
      expect(item_by_min_price.name).to eq('Chicken Cutlet')
      
      
      search_params = { min_price: 4.00, max_price: 5.00 }
      item_by_min_price = Item.find_one(search_params)
      expect(item_by_min_price.name).to eq('Maple Syrup')
    end
  end
end
