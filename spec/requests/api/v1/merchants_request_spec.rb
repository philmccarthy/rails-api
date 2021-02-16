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
        merchant[:id] == merchant_on_page_5.id.to_s
      end
      
      check_for_page_1_merchant = page_5_merchants[:data].any? do |merchant| 
        merchant[:id] == merchant_on_page_1.id.to_s
      end
      
      check_for_last_page_merchant = page_5_merchants[:data].any? do |merchant| 
        merchant[:id] == merchant_on_last_page.id.to_s
      end

      expect(check_for_correct_merchant).to be true
      expect(check_for_page_1_merchant).to be false
      expect(check_for_last_page_merchant).to be false
    end

    it 'can get one merchant by its id' do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(merchant).to have_key :data
      expect(merchant).to be_a Hash

      expect(merchant[:data]).to have_key :type
      expect(merchant[:data][:type]).to be_a String

      expect(merchant[:data]).to have_key :id
      expect(merchant[:data][:id]).to be_a String

      expect(merchant[:data]).to have_key :attributes
      expect(merchant[:data][:attributes]).to be_a Hash

      expect(merchant[:data][:attributes]).to have_key :name
      expect(merchant[:data][:attributes][:name]).to be_a String
    end

    it 'returns the merchant associated with an item' do
      create(:merchant_with_items)
      item = Item.first
      merchant_name = item.merchant.name
      
      get "/api/v1/items/#{item.id}/merchant"

      merchant = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(merchant[:data][:attributes][:name]).to eq(merchant_name)
      
      expect(merchant).to have_key :data
      expect(merchant).to be_a Hash
      
      expect(merchant[:data]).to have_key :type
      expect(merchant[:data][:type]).to be_a String
      
      expect(merchant[:data]).to have_key :id
      expect(merchant[:data][:id]).to be_a String
      
      expect(merchant[:data]).to have_key :attributes
      expect(merchant[:data][:attributes]).to be_a Hash
      
      expect(merchant[:data][:attributes]).to have_key :name
      expect(merchant[:data][:attributes][:name]).to be_a String
    end

    it 'finds all merchants by search criteria' do
      merch_1 = create(:merchant, name: 'Merchez One')
      merch_2 = create(:merchant, name: 'Merchant Two')
      merch_3 = create(:merchant, name: 'Merchea Three')
      excluded_merch = create(:merchant, name: 'Plopadopalous')

      get '/api/v1/merchants/find_all', params: { name: 'merch' }

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data].count).to eq(3)
      
      merchant_names = merchants[:data].map do |merchant| 
        merchant[:attributes][:name]
      end
      
      expect(merchant_names).to eq([merch_2.name, merch_3.name, merch_1.name])
    end
  end

  # --> SAD PATH

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

    it 'find all merchants endpoint returns an empty array if given an empty string parameter' do
      create_list(:merchant, 3)

      get '/api/v1/merchants/find_all', params: { name: '' }

      expect(response).to be_successful

      merchants = JSON.parse(response.body, symbolize_names: true)

      expect(merchants[:data]).to be_an Array
      expect(merchants[:data]).to be_empty
    end
  end
end
