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
end
