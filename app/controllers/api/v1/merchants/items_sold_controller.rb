class Api::V1::Merchants::ItemsSoldController < ApplicationController
  def index
    # Project spec for this endpoint requires 
    # an error if no quantity param given
    return invalid_quantity_param_error if params[:quantity].nil?
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: ItemsSoldSerializer.new(Merchant.most_items_sold(params[:quantity]))
  end
end