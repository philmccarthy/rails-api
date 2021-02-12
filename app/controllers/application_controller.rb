class ApplicationController < ActionController::API
  def results_per_page
    return params[:per_page].to_i if params[:per_page].to_i > 0
    20
  end

  def page_number
    return params[:page].to_i if params[:page].to_i >= 1
    1
  end
end
