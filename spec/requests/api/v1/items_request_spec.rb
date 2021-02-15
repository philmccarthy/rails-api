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

    it 'returns the items associated with a merchant' do
      merchant = create(:merchant_with_items)

      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to be_a Hash
      expect(items[:data]).to be_an Array

      expect(items[:data].size).to eq(10)

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

    it 'can create an item' do
      item_params = attributes_for(:item)
      headers = { "CONTENT_TYPE" => "application/json" }

      post '/api/v1/items', headers: headers, params: JSON.generate(item_params)
      created_item = Item.last
      
      expected_body = {
        data: {
          id: created_item.id.to_s,
          type: 'item',
          attributes: {
            name: created_item.name,
            description: created_item.description,
            unit_price: created_item.unit_price.to_f,
            merchant_id: created_item.merchant_id
          }
        }
      }
      
      actual_body = JSON.parse(response.body, symbolize_names: true)

      expect(actual_body).to eq(expected_body)
      expect(response).to be_successful
      expect(created_item.name).to eq(item_params[:name])
      expect(created_item.description).to eq(item_params[:description])
      expect(created_item.unit_price.to_f).to eq(item_params[:unit_price])
      expect(created_item.merchant_id).to eq(item_params[:merchant_id])
      
    end

    it 'can destroy an item' do
      item = create(:item)
      
      expect{ delete "/api/v1/items/#{item.id}" }.to change(Item, :count).by(-1)

      expect(response).to be_successful

      expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'can update an item' do
      og_item = create(:item)
      og_name = og_item.name
      item_params = { name: 'FRESH NEW NEW Spice' }
      headers = { "CONTENT_TYPE" => 'application/json' }

      patch "/api/v1/items/#{og_item.id}", headers: headers, params: JSON.generate(item_params)

      updated_item = Item.find(og_item.id)

      expect(response).to be_successful
      expect(updated_item.name).to_not eq(og_name)
      expect(updated_item.name).to eq(item_params[:name])
    end
  end

  describe 'sad path' do
    it 'returns 404 if the item does not exist' do
      non_existent_id = 1231231

      get "/api/v1/items/#{non_existent_id}"

      expect(response).to_not be_successful

      actual_body = JSON.parse(response.body, symbolize_names: true)
      expected_body = {
        message: "Your query could not be executed...what have you done?",
        errors: [
          "Couldn't find Item with 'id'=1231231"
        ]
      }

      expect(actual_body).to eq(expected_body)
    end

    it "cannot update an item's merchant with a non-existent merchant" do
      og_item = create(:item)
      item_params = { merchant_id: '1000' }
      headers = { "CONTENT_TYPE" => 'application/json' }

      patch "/api/v1/items/#{og_item.id}", headers: headers, params: JSON.generate(item_params)

      expect(response).to_not be_successful
    end
  end
end
