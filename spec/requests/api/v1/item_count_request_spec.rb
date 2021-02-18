require 'rails_helper'

describe('Item Count API Request', use_before: true) do
  before(:each, use_before: true) do
    @merchant_1 = create(:merchant_with_items)
    @invoice_1 = create(:invoice, merchant: @merchant_1, status: 'shipped')
    create(:invoice_item, item: @merchant_1.items.first, invoice: @invoice_1, quantity: 10, unit_price: 10.00)
    create(:transaction, invoice: @invoice_1)
    
    @merchant_2 = create(:merchant_with_items)
    @invoice_2 = create(:invoice, merchant: @merchant_2, status: 'shipped')
    create(:invoice_item, item: @merchant_2.items.first, invoice: @invoice_2, quantity: 20, unit_price: 10.00)
    create(:invoice_item, item: @merchant_2.items.second, invoice: @invoice_2, quantity: 1, unit_price: 100.00)
    create(:transaction, invoice: @invoice_2)
  end
  
  describe'Happy Path' do
    it 'sends a list of merchants ranked by count of items sold' do
      get '/api/v1/merchants/most_items', params: { quantity: 2 }

      merchants_by_item_count = JSON.parse(response.body, symbolize_names: true)

      expect(merchants_by_item_count).to be_a Hash

      expect(merchants_by_item_count).to have_key :data
      expect(merchants_by_item_count[:data]).to be_an Array

      expect(merchants_by_item_count[:data][0]).to have_key :id
      expect(merchants_by_item_count[:data][0][:id]).to be_a String

      expect(merchants_by_item_count[:data][0]).to have_key :type
      expect(merchants_by_item_count[:data][0][:type]).to eq('items_sold')

      expect(merchants_by_item_count[:data][0]).to have_key :attributes
      expect(merchants_by_item_count[:data][0][:attributes]).to be_a Hash

      expect(merchants_by_item_count[:data][0][:attributes]).to have_key :name
      expect(merchants_by_item_count[:data][0][:attributes][:name]).to be_a String

      expect(merchants_by_item_count[:data][0][:attributes]).to have_key :count
      expect(merchants_by_item_count[:data][0][:attributes][:count]).to be_a Integer
    end

    it 'returns all merchants with count if given a qty param that is bigger than the data set' do
      get '/api/v1/merchants/most_items', params: { quantity: 10000 }
      
      merchants_by_item_count = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(merchants_by_item_count[:data].size).to eq(2)
    end
  end

  describe 'Sad Path', use_before: false do
    it 'if merchants by items sold request is given no qty parameter an error is returned' do
      get '/api/v1/merchants/most_items', params: { quantity: '' }

      error_object = JSON.parse(response.body, symbolize_names: true)

      expect(error_object).to be_a Hash

      expect(error_object).to have_key :message
      expect(error_object[:message]).to be_a String
      expect(error_object[:message]).to eq('Invalid Parameters')

      
      expect(error_object).to have_key :error
      expect(error_object[:error]).to be_an Array
      expect(error_object[:error][0]).to eq('quantity parameter was invalid. Try again')
    end

    it 'if merchants by items sold request is given a negative qty param an error is returned', use_before: false do
      get '/api/v1/merchants/most_items', params: { quantity: -100 }

      error_object = JSON.parse(response.body, symbolize_names: true)

      expect(error_object).to be_a Hash

      expect(error_object).to have_key :message
      expect(error_object[:message]).to be_a String
      expect(error_object[:message]).to eq('Invalid Parameters')
      
      expect(error_object).to have_key :error
      expect(error_object[:error]).to be_an Array
      expect(error_object[:error][0]).to eq('quantity parameter was invalid. Try again')
    end

    it 'if merchants by items sold request is given a wordy (non-integer) qty param an error is returned', use_before: false do
      get '/api/v1/merchants/most_items', params: { quantity: 'asdajsh' }

      error_object = JSON.parse(response.body, symbolize_names: true)

      expect(error_object).to have_key :message
      expect(error_object[:message]).to be_a String
      expect(error_object[:message]).to eq('Invalid Parameters')

      expect(error_object).to be_a Hash
      
      expect(error_object).to have_key :error
      expect(error_object[:error]).to be_an Array
      expect(error_object[:error][0]).to eq('quantity parameter was invalid. Try again')
    end
  end
end
