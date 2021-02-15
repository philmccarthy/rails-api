class Api::V1::MerchantsController < ApplicationController
  before_action :set_item, only: [:show]

  def index
    render json: MerchantSerializer.new(
      Merchant.retrieve_many results_per_page, page_number
    )
  end

  def show
    if @item
      render json: MerchantSerializer.new(@item.merchant)
    else
      render json: MerchantSerializer.new(Merchant.find params[:id])
    end
  end

  def find_all
    render json: MerchantSerializer.new(
      Merchant.search_by_name(params[:name])
    )
  end

  private

  def set_item
    if params[:item_id]
      @item = Item.find(params[:item_id])
    end
  end
end
