module Api
  module V1
    class MerchantsController < ApplicationController
      before_action :set_item, only: [:show]

      def index
        render json: MerchantSerializer.new(
          Merchant.retrieve_many(results_per_page, page_number)
        )
      end

      def show
        if @item
          render json: MerchantSerializer.new(@item.merchant)
        else
          render json: MerchantSerializer.new(
            Merchant.find(params[:id])
          )
        end
      end

      private

      def set_item
        @item = Item.find(params[:item_id]) if params[:item_id]
      end
    end
  end
end
