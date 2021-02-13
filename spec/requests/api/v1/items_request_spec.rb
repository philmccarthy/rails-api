require 'rails_helper'

describe 'items API' do
  describe 'happy path' do
    it 'sends a list of items with proper JSON format' do
      create_list(:item, 5)
      
      get '/api/v1/items'

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to be_a Hash
      expect(items[:data]).to be_an Array

      expect(items[:data].size).to eq(5)

      items[:data].each do |item|
        expect(item).to have_key :id
        expect(item[:id]).to be_a String

        expect(item).to have_key :type
        expect(item[:type]).to be_a String

        expect(item).to have_key :attributes
        expect(item[:attributes]).to be_a Hash

        expect(item[:attributes]).to have_key :name
        expect(item[:attributes][:name]).to be_a String
        
        expect(item[:attributes]).to have_key :description
        expect(item[:attributes][:description]).to be_a String
        
        expect(item[:attributes]).to have_key :unit_price
        expect(item[:attributes][:unit_price]).to be_a Numeric
        
        expect(item[:attributes]).to have_key :merchant_id
        expect(item[:attributes][:merchant_id]).to be_a Numeric
      end
    end

    it 'can get one item by its id' do
      id = create(:item).id

      get "/api/v1/items/#{id}"

      item = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(item[:data]).to have_key :id
      expect(item[:data][:id]).to be_a String

      expect(item[:data]).to have_key :type
      expect(item[:data][:type]).to be_a String

      expect(item[:data]).to have_key :attributes
      expect(item[:data][:attributes]).to be_a Hash

      expect(item[:data][:attributes]).to have_key :name
      expect(item[:data][:attributes][:name]).to be_a String
      
      expect(item[:data][:attributes]).to have_key :description
      expect(item[:data][:attributes][:description]).to be_a String
      
      expect(item[:data][:attributes]).to have_key :unit_price
      expect(item[:data][:attributes][:unit_price]).to be_a Numeric
      
      expect(item[:data][:attributes]).to have_key :merchant_id
      expect(item[:data][:attributes][:merchant_id]).to be_a Numeric
    end
  end

  describe 'sad path' do
    it 'it returns 404 if the item does not exist' do
      non_existent_id = 1231231

      get "/api/v1/items/#{non_existent_id}"

      expect(response).to be_unsuccessful
    end
  end
end
