# frozen_string_literal: true

module Api
  module V1
    module Revenue
      class MerchantsController < ApplicationController
        def index
          # Project spec for this endpoint requires
          # an error if no quantity param given
          return invalid_quantity_param_error if params[:quantity].nil?
          return invalid_quantity_param_error if invalid_quantity_param?

          render json: MerchantNameRevenueSerializer.new(
            Merchant.most_revenue(params[:quantity])
          )
        end

        def show
          merchant = Merchant.find(params[:id])
          render json: MerchantRevenueSerializer.new(
            Merchant.total_revenue(merchant.id)
          )
        end
      end
    end
  end
end
