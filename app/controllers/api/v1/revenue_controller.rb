class Api::V1::RevenueController < ApplicationController
  def merchants_with_most_revenue
    # Project spec for this endpoint requires 
    # an error if no quantity param given
    return invalid_quantity_param_error if params[:quantity].nil?
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: MerchantNameRevenueSerializer.new(Merchant.most_revenue(params[:quantity]))
  end
  
  def items_with_most_revenue
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: ItemRevenueSerializer.new(Item.top_ten_by_revenue(params[:quantity]))
  end

  def merchant_revenue
    merchant = Merchant.find(params[:id])
    render json: MerchantRevenueSerializer.new(Merchant.total_revenue(merchant.id))
  end
end
