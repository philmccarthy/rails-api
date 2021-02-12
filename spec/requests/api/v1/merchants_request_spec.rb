require 'rails_helper'

describe 'merchants API' do
  it 'sends a list of merchants with proper JSON format' do
    create_list(:merchant, 5)
    
    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

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
