require 'rails_helper'

describe('Revenue API requests', use_before: true) do
  before(:each, use_before: true) do
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

  describe 'Merchants with Most Revenue' do
    describe 'Happy Path' do
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

      it 'returns all merchants revenue if given a qty param that is bigger than the data set' do
        get '/api/v1/revenue/merchants', params: { quantity: 10000 }
        
        most_revenue_merchants = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(most_revenue_merchants[:data].size).to eq(2)
      end
    end

    describe 'Sad Path' do
      it 'returns an error if quantity param is an empty string', use_before: false do
        get '/api/v1/revenue/merchants', params: { quantity: '' }

        error_object = JSON.parse(response.body, symbolize_names: true)
  
        expect(error_object).to be_a Hash
  
        expect(error_object).to have_key :message
        expect(error_object[:message]).to eq('Invalid Parameters')
        
        expect(error_object).to have_key :error
        expect(error_object[:error]).to be_an Array
        expect(error_object[:error][0]).to eq('quantity parameter was invalid. Try again')
      end

      it 'returns an error if quantity param is not numeric', use_before: false do
        get '/api/v1/revenue/merchants', params: { quantity: 'asfadfa' }

        error_object = JSON.parse(response.body, symbolize_names: true)

        expect(error_object).to be_a Hash
  
        expect(error_object).to have_key :message
        expect(error_object[:message]).to eq('Invalid Parameters')
        
        expect(error_object).to have_key :error
        expect(error_object[:error]).to be_an Array
        expect(error_object[:error][0]).to eq('quantity parameter was invalid. Try again')
      end
      
      it 'returns an error if quantity param is not provided', use_before: false do
        get '/api/v1/revenue/merchants'

        error_object = JSON.parse(response.body, symbolize_names: true)

        expect(error_object).to be_a Hash
  
        expect(error_object).to have_key :message
        expect(error_object[:message]).to eq('Invalid Parameters')
        
        expect(error_object).to have_key :error
        expect(error_object[:error]).to be_an Array
        expect(error_object[:error][0]).to eq('quantity parameter was invalid. Try again')
      end
    end
  end

  describe 'Items with Most Revenue' do
    describe 'Happy Path' do
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

      it 'returns all items revenue if given a qty param that is bigger than the data set' do
        get '/api/v1/revenue/items', params: { quantity: 10000 }
        
        most_revenue_items = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful
        expect(most_revenue_items[:data].size).to eq(3)
      end
    end

    describe 'Sad Path' do
      it 'returns an error if given a quantity parameter that isnt Numeric', use_before: false do
        get '/api/v1/revenue/items', params: { quantity: 'asdfg' }
  
        invalid_parameters_response = JSON.parse(response.body, symbolize_names: true)
  
        expect(invalid_parameters_response).to be_a Hash
  
        expect(invalid_parameters_response).to have_key :message
        expect(invalid_parameters_response[:message]).to eq('Invalid Parameters')
        
        expect(invalid_parameters_response).to have_key :error
        expect(invalid_parameters_response[:error]).to be_an Array
        expect(invalid_parameters_response[:error][0]).to eq('quantity parameter was invalid. Try again')
      end

      it 'returns an error if given a quantity parameter that is negative', use_before: false do
        get '/api/v1/revenue/items', params: { quantity: '-100' }
  
        invalid_parameters_response = JSON.parse(response.body, symbolize_names: true)
  
        expect(invalid_parameters_response).to be_a Hash
  
        expect(invalid_parameters_response).to have_key :message
        expect(invalid_parameters_response[:message]).to eq('Invalid Parameters')
        
        expect(invalid_parameters_response).to have_key :error
        expect(invalid_parameters_response[:error]).to be_an Array
        expect(invalid_parameters_response[:error][0]).to eq('quantity parameter was invalid. Try again')
      end

      it 'returns an error if given a quantity parameter that is blank', use_before: false do
        get '/api/v1/revenue/items', params: { quantity: '' }
  
        invalid_parameters_response = JSON.parse(response.body, symbolize_names: true)
  
        expect(invalid_parameters_response).to be_a Hash
  
        expect(invalid_parameters_response).to have_key :message
        expect(invalid_parameters_response[:message]).to eq('Invalid Parameters')
        
        expect(invalid_parameters_response).to have_key :error
        expect(invalid_parameters_response[:error]).to be_an Array
        expect(invalid_parameters_response[:error][0]).to eq('quantity parameter was invalid. Try again')
      end
    end
  end

  describe 'Merchant Total Revenue' do
    describe 'Happy Path' do
      it 'returns total revenue for a single merchant' do
        get "/api/v1/revenue/merchants/#{@merchant_1.id}"

        merchant_with_revenue = JSON.parse(response.body, symbolize_names: true)

        expect(response).to be_successful

        expect(merchant_with_revenue).to be_a Hash

        expect(merchant_with_revenue).to have_key :data
        expect(merchant_with_revenue[:data]).to be_a Hash
        
        expect(merchant_with_revenue[:data]).to have_key :id
        expect(merchant_with_revenue[:data][:id]).to be_a String
        
        expect(merchant_with_revenue[:data]).to have_key :type
        expect(merchant_with_revenue[:data][:type]).to be_a String

        expect(merchant_with_revenue[:data]).to have_key :attributes
        expect(merchant_with_revenue[:data][:attributes]).to be_a Hash

        expect(merchant_with_revenue[:data][:attributes]).to have_key :revenue
        expect(merchant_with_revenue[:data][:attributes][:revenue]).to be_a Numeric
      end
    end

    describe 'Sad Path' do
      it 'returns an error if the merchant requested cant be found' do
        get "/api/v1/revenue/merchants/12345678991234565"
        
        expect(response).to_not be_successful

        error_object = JSON.parse(response.body, symbolize_names: true)

        expect(error_object).to be_a Hash

        expect(error_object).to have_key :message
        expect(error_object[:message]).to be_a String
        expect(error_object[:message]).to eq('Your query could not be executed...what have you done?')
        
        expect(error_object).to have_key :errors
        expect(error_object[:errors]).to be_an Array
        expect(error_object[:errors][0]).to eq("Couldn't find Merchant with 'id'=12345678991234565")
      end
    end
  end
end
