class Api::V1::RevenueController < ApplicationController
  def merchants_with_most_revenue
    # Project spec for this endpoint requires 
    # an error if no quantity param given
    return invalid_quantity_param_error if params[:quantity].nil?
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: MerchantNameRevenueSerializer.new(
      Merchant.most_revenue(params[:quantity])
    )
  end
  
  def items_with_most_revenue
    # Project spec for this endpoint allows
    # quantity param to be optional
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: ItemRevenueSerializer.new(
      Item.most_revenue(params[:quantity])
    )
  end

  def merchant_revenue
    merchant = Merchant.find(params[:id])
    render json: MerchantRevenueSerializer.new(
      Merchant.total_revenue(merchant.id)
    )
  end

  def unshipped_invoices
    return invalid_quantity_param_error if invalid_quantity_param?
    render json: UnshippedOrderSerializer.new(
      Invoice.unshipped_potential_revenue(params[:quantity])
    )
  end
end
