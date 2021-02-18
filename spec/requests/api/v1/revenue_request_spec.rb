require 'rails_helper'

describe 'Revenue API requests' do
  describe 'Happy Path' do
    before(:each) do
      @merchant_1 = create(:merchant_with_items)
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

    it 'sends a list of merchants ranked by revenue' do
      get '/api/v1/revenue/merchants', params: { quantity: 2 }
      
      most_revenue_merchants = JSON.parse(response.body, symbolize_names: true)

      expect(most_revenue_merchants).to have_key :data
      expect(most_revenue_merchants).to be_a Hash

      expect(most_revenue_merchants[:data][0]).to have_key :id
      expect(most_revenue_merchants[:data][0][:id]).to be_a String

      expect(most_revenue_merchants[:data][0]).to have_key :type
      expect(most_revenue_merchants[:data][0][:type]).to eq('merchant_name_revenue')

      expect(most_revenue_merchants[:data][0]).to have_key :attributes
      expect(most_revenue_merchants[:data][0][:attributes]).to be_a Hash

      expect(most_revenue_merchants[:data][0][:attributes]).to have_key :name
      expect(most_revenue_merchants[:data][0][:attributes][:name]).to be_a String

      expect(most_revenue_merchants[:data][0][:attributes]).to have_key :revenue
      expect(most_revenue_merchants[:data][0][:attributes][:revenue]).to be_a Numeric
      
      expect(most_revenue_merchants[:data].size).to eq(2)

      expect(most_revenue_merchants[:data][0][:attributes][:revenue]).to eq(300)
      expect(most_revenue_merchants[:data][1][:attributes][:revenue]).to eq(100)
    end

    it 'sends a list of items ranked by revenue' do
      get '/api/v1/revenue/items', params: { quantity: 3 }

      most_revenue_items = JSON.parse(response.body, symbolize_names: true)

      expect(most_revenue_items).to have_key :data
      expect(most_revenue_items).to be_a Hash

      expect(most_revenue_items[:data][0]).to have_key :id
      expect(most_revenue_items[:data][0][:id]).to be_a String

      expect(most_revenue_items[:data][0]).to have_key :type
      expect(most_revenue_items[:data][0][:type]).to eq('item_revenue')

      expect(most_revenue_items[:data][0]).to have_key :attributes
      expect(most_revenue_items[:data][0][:attributes]).to be_a Hash

      expect(most_revenue_items[:data][0][:attributes]).to have_key :name
      expect(most_revenue_items[:data][0][:attributes][:name]).to be_a String

      expect(most_revenue_items[:data][0][:attributes]).to have_key :description
      expect(most_revenue_items[:data][0][:attributes][:description]).to be_a String

      expect(most_revenue_items[:data][0][:attributes]).to have_key :unit_price
      expect(most_revenue_items[:data][0][:attributes][:unit_price]).to be_a Numeric

      expect(most_revenue_items[:data][0][:attributes]).to have_key :merchant_id
      expect(most_revenue_items[:data][0][:attributes][:merchant_id]).to be_an Integer

      expect(most_revenue_items[:data][0][:attributes]).to have_key :revenue
      expect(most_revenue_items[:data][0][:attributes][:revenue]).to be_a Numeric
      
      expect(most_revenue_items[:data].size).to eq(3)
      expect(most_revenue_items[:data][0][:attributes][:revenue]).to eq(200)
      expect(most_revenue_items[:data][1][:attributes][:revenue]).to eq(100)
    end

    it 'sends a list of merchants with the most items sold' do
      
    end
  end
end
