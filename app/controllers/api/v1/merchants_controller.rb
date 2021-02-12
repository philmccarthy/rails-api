class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(
      Merchant.retrieve results_per_page, page_number
    )
  end
end
