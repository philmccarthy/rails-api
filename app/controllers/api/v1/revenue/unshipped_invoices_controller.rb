# frozen_string_literal: true

module Api
  module V1
    module Revenue
      class UnshippedInvoicesController < ApplicationController
        def index
          return invalid_quantity_param_error if invalid_quantity_param?

          render json: UnshippedOrderSerializer.new(
            Invoice.unshipped_potential_revenue(params[:quantity])
          )
        end
      end
    end
  end
end
