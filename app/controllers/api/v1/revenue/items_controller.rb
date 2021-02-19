module Api
  module V1
    module Revenue
      class ItemsController < ApplicationController
        def index
          # Project spec for this endpoint allows
          # quantity param to be optional
          return invalid_quantity_param_error if invalid_quantity_param?

          render json: ItemRevenueSerializer.new(
            Item.most_revenue(params[:quantity])
          )
        end
      end
    end
  end
end
