class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(
      Item.retrieve_many results_per_page, page_number
    )
  end

  def show
    render json: ItemSerializer.new(
      Item.find params[:id]
    )
  end

  def create
    render json: ItemSerializer.new(
      Item.create!(item_params)
    ), status: :created
  end

  def update
    render json: ItemSerializer.new(
      Item.update(params[:id], item_params)
    )
  end

  def destroy
    Item.destroy(params[:id])
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
