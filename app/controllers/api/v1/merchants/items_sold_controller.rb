# frozen_string_literal: true

module Api
  module V1
    module Merchants
      class ItemsSoldController < ApplicationController
        def index
          # Project spec for this endpoint requires
          # an error if no quantity param given
          return invalid_quantity_param_error if params[:quantity].nil?
          return invalid_quantity_param_error if invalid_quantity_param?

          render json: ItemsSoldSerializer.new(Merchant.most_items_sold(params[:quantity]))
        end
      end
    end
  end
end
