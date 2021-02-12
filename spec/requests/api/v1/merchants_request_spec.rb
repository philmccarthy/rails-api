require 'rails_helper'

describe 'merchants API' do
  describe 'happy path' do
    it 'sends a list of merchants with proper JSON format' do
      create_list(:merchant, 5)
      
      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants).to be_an Hash
      expect(merchants[:data]).to be_an Array

      expect(merchants[:data].size).to eq(5)

      merchants[:data].each do |merchant|
        expect(merchant).to have_key :id
        expect(merchant[:id]).to be_a String

        expect(merchant).to have_key :type
        expect(merchant[:type]).to be_a String

        expect(merchant).to have_key :attributes
        expect(merchant[:attributes]).to be_a Hash

        expect(merchant[:attributes]).to have_key :id
        expect(merchant[:attributes][:id]).to be_an Integer

        expect(merchant[:attributes]).to have_key :name
        expect(merchant[:attributes][:name]).to be_a String
      end
    end

    it 'accepts query param of per page results and returns 20 merchants by default' do
      create_list(:merchant, 25)
      
      get '/api/v1/merchants'
      expect(response).to be_successful
      
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].size).to eq(20)

      get '/api/v1/merchants', params: { per_page: '25' }

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].size).to eq(25)
    end

    it 'accepts query param of page number and returns paginated results' do
      create_list(:merchant, 51)
      merchant_on_page_1 = Merchant.first
      merchant_on_last_page = Merchant.last

      merchant_on_page_5 = Merchant.forty_two
      
      get '/api/v1/merchants', params: { per_page: '10', page: 5 }

      page_5_merchants = JSON.parse(response.body, symbolize_names: true)

      check_for_correct_merchant = page_5_merchants[:data].any? do |merchant| 
          merchant[:attributes][:id] == merchant_on_page_5.id
        end
      
      check_for_page_1_merchant = page_5_merchants[:data].any? do |merchant| 
        merchant[:attributes][:id] == merchant_on_page_1.id
      end
      
      check_for_last_page_merchant = page_5_merchants[:data].any? do |merchant| 
        merchant[:attributes][:id] == merchant_on_last_page.id
      end
      
      expect(check_for_correct_merchant).to be true
      expect(check_for_page_1_merchant).to be false
      expect(check_for_last_page_merchant).to be false
    end
  end

  describe 'sad path' do
    it 'returns page 1 if given a pagination request for page 0 or negative' do
      create_list(:merchant, 5)

      get '/api/v1/merchants', params: { page: 0 }
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(merchants).not_to be_empty
      
      get '/api/v1/merchants', params: { page: -100 }
      merchants = JSON.parse(response.body, symbolize_names: true)
      
      expect(response).to be_successful
      expect(merchants).not_to be_empty
    end
    
    it 'returns default results_per_page if given 0 or fewer as a query param' do
      create_list(:merchant, 30)
      
      get '/api/v1/merchants', params: { per_page: -10 }
      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(merchants[:data].size).to eq(20)
    end
  end
end
