class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(
      Merchant.retrieve_many results_per_page, page_number
    )
  end

  def show
    render json: MerchantSerializer.new(
      Merchant.find params[:id]
    )
  end
end
