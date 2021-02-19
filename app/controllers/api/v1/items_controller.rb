module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_merchant, only: [:index]

      def index
        if @merchant
          render json: ItemSerializer.new(@merchant.items)
        else
          render json: ItemSerializer.new(Item.retrieve_many(results_per_page, page_number))
        end
      end

      def show
        render json: ItemSerializer.new(Item.find(params[:id]))
      end

      def create
        render json: ItemSerializer.new(Item.create!(item_params)), status: :created
      end

      def update
        item = Item.find(params[:id])
        item.update!(item_params)
        render json: ItemSerializer.new(item)
      end

      def destroy
        Item.destroy(params[:id])
      end

      private

      def item_params
        if params[:merchant_id]
          Merchant.find(params[:merchant_id])
          params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
        else
          params.require(:item).permit(:name, :description, :unit_price)
        end
      end

      def set_merchant
        @merchant = Merchant.find(params[:merchant_id]) if params[:merchant_id]
      end
    end
  end
end
