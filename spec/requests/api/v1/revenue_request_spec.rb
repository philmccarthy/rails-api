require 'rails_helper'

describe 'Revenue API requests' do
  describe 'Happy Path' do
    it 'sends a list of merchants ranked by revenue' do
      create(:merchant_with_items)
      
      get '/api/v1/revenue/merchants', params: { quantity: 2 }

      

    end
  end
end