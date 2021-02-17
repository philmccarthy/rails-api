require 'rails_helper'

describe 'Items API requests' do
  describe 'Happy Path' do
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

    it 'accepts query param of page number and returns paginated results' do
      create_list(:item, 51)
      item_on_page_1 = Item.first
      item_on_last_page = Item.last

      item_on_page_5 = Item.forty_two
      
      get '/api/v1/items', params: { per_page: '10', page: 5 }

      page_5_items = JSON.parse(response.body, symbolize_names: true)

      check_for_correct_item = page_5_items[:data].any? do |item| 
        item[:id] == item_on_page_5.id.to_s
      end
      
      check_for_page_1_item = page_5_items[:data].any? do |item| 
        item[:id] == item_on_page_1.id.to_s
      end
      
      check_for_last_page_item = page_5_items[:data].any? do |item| 
        item[:id] == item_on_last_page.id.to_s
      end

      expect(check_for_correct_item).to be true
      expect(check_for_page_1_item).to be false
      expect(check_for_last_page_item).to be false
    end

    it 'returns data for one item when requested by its id' do
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

    it 'returns all items that belong to a requested merchant id' do
      merchant = create(:merchant_with_items)

      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to be_a Hash
      expect(items[:data]).to be_an Array

      expect(items[:data].size).to eq(10)
    end

    it "can accept a request to create an item and return that new item's data" do
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

    it 'can destroy an item and its associated invoices where its the only item' do
      item = create(:item_with_invoices)
      expect(Invoice.count).to eq(5)
      
      expect{ delete "/api/v1/items/#{item.id}" }.to change(Item, :count).by(-1)
      expect(Invoice.count).to eq(0)

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

    it 'can return one item by a search of name—then description if no name matches—and return first result based on order by name' do
      create(:item, name: 'Alphabet Soup')
      create(:item, name: 'Alphabet GOOG')
      create(:item, description: 'A description that is different.')

      # Return the first match based on alphabetical order.
      search_params = { name: 'alPHa' }
      get '/api/v1/items/find', params: search_params
      
      search_result = JSON.parse(response.body, symbolize_names: true)
      expect(search_result.size).to eq(1)
      expect(search_result[:data][:attributes][:name]).to eq('Alphabet GOOG')
      
      # Return the only matching item.
      search_params = { name: 'soup' }
      get '/api/v1/items/find', params: search_params

      search_result = JSON.parse(response.body, symbolize_names: true)
      expect(search_result[:data][:attributes][:name]).to eq('Alphabet Soup')

      search_params = { name: 'diff' }
      get '/api/v1/items/find', params: search_params

      # If no items.name match, return an items.description match.
      search_result = JSON.parse(response.body, symbolize_names: true)
      expect(search_result[:data][:attributes][:description]).to eq('A description that is different.')
    end

    it 'can return one item by search of MIN price with result based on order by name' do
      create(:item, name: 'Alphabet Soup', unit_price: 7.50)
      create(:item, name: 'Alphabet GOOG', unit_price: 5.50)
      
      search_params = { min_price: 5 }
      get '/api/v1/items/find', params: search_params

      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result[:data][:attributes][:name]).to eq('Alphabet GOOG')
    end

    it 'can return an equal-to exact min_price match' do
      create(:item, name: 'Alphabet Soup', unit_price: 7.50)
      create(:item, name: 'Alphabet GOOG', unit_price: 5.50)

      search_params = { min_price: 7.50 }
      get '/api/v1/items/find', params: search_params

      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result[:data][:attributes][:name]).to eq('Alphabet Soup')
    end
    
    it 'can return one item by search of MAX price with result based on order by name' do
      create(:item, name: 'Alphabet Soup', unit_price: 7.50)
      create(:item, name: 'Alphabet GOOG', unit_price: 8.50)
      
      search_params = { max_price: 8.00 }
      get '/api/v1/items/find', params: search_params

      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result[:data][:attributes][:name]).to eq('Alphabet Soup')
    end

    it 'can return one result by max price when two match based on order by name' do
      create(:item, name: 'Alphabet Soup', unit_price: 7.50)
      create(:item, name: 'Alphabet GOOG', unit_price: 5.50)

      search_params = { max_price: 7.50 }
      get '/api/v1/items/find', params: search_params

      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result[:data][:attributes][:name]).to eq('Alphabet GOOG')
    end

    it 'can return one item by search of MIN & MAX prices with result based on order by name' do
      create(:item, name: 'Backwards Alphabet', unit_price: 5.50)
      create(:item, name: 'Alphabet Soup', unit_price: 7.50)
      create(:item, name: 'Alphabet GOOG', unit_price: 5.00)
      
      search_params = { min_price: 5.50, max_price: 7.50 }
      get '/api/v1/items/find', params: search_params

      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result[:data][:attributes][:name]).to eq('Alphabet Soup')
    end
  end

  # --> SAD PATH

  describe 'sad path' do
    it 'returns 404 if a requested item does not exist' do
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

    it 'returns error messages if an Update request fails item model validations' do
      og_item = create(:item)
      item_params = { unit_price: -100, name: '', description: '' }
      headers = { "CONTENT_TYPE" => 'application/json' }
      
      patch "/api/v1/items/#{og_item.id}", headers: headers, params: JSON.generate(item_params)
      
      expected_errors = {
        message: "Your request failed...perhaps you could be better.",
        errors: [
          "Name can't be blank",
          "Description can't be blank",
          "Unit price must be greater than 0"
        ]
      }

      actual_errors = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(actual_errors).to be_a Hash
      expect(actual_errors).to have_key :message
      expect(actual_errors).to have_key :errors
      expect(actual_errors).to eq(expected_errors)
    end

    it 'returns error messages if a Create request fails item model validations' do
      item_params = attributes_for(:item, unit_price: -100)
      headers = { "CONTENT_TYPE" => "application/json" }

      post '/api/v1/items', headers: headers, params: JSON.generate(item_params)
      
      expected_errors = {
        message: "Your request failed...perhaps you could be better.",
        errors: [
          "Unit price must be greater than 0"
        ]
      }

      actual_errors = JSON.parse(response.body, symbolize_names: true)

      expect(response).to_not be_successful
      expect(actual_errors).to eq(expected_errors)
    end

    it 'when find one item query has no matches it successfully renders json with an empty hash' do
      search_params = { name: 'no items exist!' }

      get '/api/v1/items/find', params: search_params
      
      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result).to have_key :data
      expect(search_result[:data]).to be_a Hash
      expect(search_result[:data].keys).to be_empty
    end

    it 'throws an error if the find one endpoint is given name and either/both price params' do
      search_params = { name: 'All the things', min_price: 50, max_price: 100 }

      get '/api/v1/items/find', params: search_params
      
      search_result = JSON.parse(response.body, symbolize_names: true)

      expect(search_result).to have_key :message
      expect(search_result[:message]).to eq('Invalid Parameters')
      
      expect(search_result).to have_key :errors
      expect(search_result[:errors].first).to be_a String
      expect(search_result[:errors].first).to eq('Cannot combine name and either min_price or max_price. Try again.')
    end
  end
end
