require 'rails_helper'

RSpec.describe Merchant, use_before: true, type: :model do
  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many(:invoice_items).through(:invoices) }
    it { should have_many(:transactions).through(:invoices) }
    it { should have_many(:customers).through(:invoices) }
  end

  describe 'class methods' do
    before(:each, use_before: true) do
      @merchant_1 = create(:merchant_with_items, name: 'The Double E Companee')
      @invoice_1 = create(:invoice, merchant: @merchant_1, status: 'shipped')
      create(:invoice_item, item: @merchant_1.items.first, invoice: @invoice_1, quantity: 10, unit_price: 10.00)
      create(:transaction, invoice: @invoice_1)
      
      @merchant_2 = create(:merchant_with_items)
      @invoice_2 = create(:invoice, merchant: @merchant_2, status: 'shipped')
      # Invoice 3 should not count toward revenue because invoice status is returned
      @invoice_3 = create(:invoice, merchant: @merchant_2, status: 'returned')
      @invoice_4 = create(:invoice, merchant: @merchant_2, status: 'shipped')
      create(:invoice_item, item: @merchant_2.items.first, invoice: @invoice_2, quantity: 20, unit_price: 10.00)
      create(:invoice_item, item: @merchant_2.items.second, invoice: @invoice_2, quantity: 1, unit_price: 100.00)
      create(:invoice_item, item: @merchant_2.items.third, invoice: @invoice_3, quantity: 1, unit_price: 100.00)
      create(:invoice_item, item: @merchant_2.items.fourth, invoice: @invoice_4, quantity: 1, unit_price: 100.00)
      create(:transaction, invoice: @invoice_2)
      create(:transaction, invoice: @invoice_3)
      create(:transaction, invoice: @invoice_4, result: 'failed')
      # Invoice 4 should not count toward revenue because transaction result failed
    end

    it '::most_revenue' do
      merchants_by_revenue = Merchant.most_revenue(2)
      revenues = merchants_by_revenue.map { |merchant| merchant.revenue }

      expect(merchants_by_revenue).to be_an ActiveRecord::Relation
      expect(revenues.size).to eq(2)
      expect(revenues).to eq([300, 100])
    end

    it '::most_items_sold' do
      merchants_by_items_sold = Merchant.most_items_sold(2)
      items_sold_count = merchants_by_items_sold.map { |merchant| merchant.count }

      expect(merchants_by_items_sold).to be_an ActiveRecord::Relation
      expect(items_sold_count.size).to eq(2)
      expect(items_sold_count).to eq([21, 10])
    end

    it '::total_revenue' do
      merchant_total_revenue = Merchant.total_revenue(@merchant_1.id)
      merchant_1_revenue = merchant_total_revenue.revenue
      merchant_1_id = merchant_total_revenue.id
      
      expect(merchant_total_revenue).to be_a Merchant
      expect(merchant_1_revenue).to eq(100)
      expect(merchant_1_id).to eq(@merchant_1.id)
    end

    it '::retrieve_many (inherited from ApplicationRecord)' do
      page_one = Merchant.retrieve_many(20, 1)
      page_two = Merchant.retrieve_many(20, 2)

      expect(page_one.size).to eq(20)
      expect(page_two.size).to eq(20)

      page_one_names = page_one.map { |merchant| merchant.name }
      page_two_names = page_two.map { |merchant| merchant.name }

      expect(page_one_names).to_not eq(page_two_names)
    end

    it '::find_all (inherited from ApplicationRecord' do
      merchants = Merchant.find_all('eE')
      expect(merchants).to_not be_empty
      expect(merchants.first).to be_a Merchant

      empty_array = Merchant.find_all('')
      expect(empty_array).to eq([])
    end
  end
end
