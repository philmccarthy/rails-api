class Api::V1::RevenueController < ApplicationController
  def merchants_with_most_revenue
    Merchant.most_revenue(params[:quantity])
    # render json: MerchantNameRevenueSerializer.new()
  end
end