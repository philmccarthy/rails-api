class Api::V1::Revenue::UnshippedInvoicesController < ApplicationController
  def index
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: UnshippedOrderSerializer.new(
      Invoice.unshipped_potential_revenue(params[:quantity])
    )
  end
end
