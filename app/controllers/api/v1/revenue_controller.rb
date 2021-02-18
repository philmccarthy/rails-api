class Api::V1::RevenueController < ApplicationController
  def merchants_with_most_revenue
    return (render json: invalid_quantity_param_error, status: :bad_request) if params[:quantity] == ''
    render json: MerchantNameRevenueSerializer.new(Merchant.most_revenue(params[:quantity]))
  end
  
  def items_with_most_revenue
    return (render json: invalid_quantity_param_error, status: :bad_request) if params[:quantity] == ''
    render json: ItemRevenueSerializer.new(Item.top_ten_by_revenue(params[:quantity]))
  end

  private 

  def invalid_quantity_param_error
    {
      message: 'Invalid Parameters',
      error: [
        'quantity parameter was invalid. Try again'
      ]
    }
  end
end
