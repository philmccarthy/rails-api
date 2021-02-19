class Api::V1::Items::SearchController < ApplicationController
  def index
    if query_params_invalid?
      render json: invalid_params_error, status: :bad_request
    else
      item_match = Item.find_one(params)
      item_match.present? ? (render json: ItemSerializer.new(item_match)) : (render json: { data: {} })
    end
  end

  private

  def query_params_invalid?
    params[:name] && (params[:min_price] || params[:max_price])
  end

  def invalid_params_error
    {
      message: 'Invalid Parameters',
      errors: [
        'Cannot combine name and either min_price or max_price. Try again.'
      ]
    }
  end
end
