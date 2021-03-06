class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def results_per_page
    return params[:per_page].to_i if params[:per_page].to_i.positive?

    # Else set default results per page
    20
  end

  def page_number
    return params[:page].to_i if params[:page].to_i >= 1

    # Else set default page number
    1
  end

  def invalid_quantity_param?
    # Guard against cases when nil applies default qty
    return false if params[:quantity].nil?

    # Invalidate if it's a blank string
    params[:quantity].blank? ||
      # or if the string does not contain a number
      !/\A\d+\z/.match(params[:quantity]) ||
      # or if after integer-ified it's negative
      params[:quantity].to_i.negative?
  end

  def render_not_found_response(exception)
    render json:
      {
        message: 'Your query could not be executed...what have you done?',
        errors: [
          exception.message
        ]
      },
      status: :not_found
  end

  def render_unprocessable_entity_response(exception)
    render json:
      {
        message: 'Your request failed...perhaps you could be better.',
        errors: exception.record.errors.full_messages
      },
      status: :unprocessable_entity
  end

  def invalid_quantity_param_error
    render json:
      {
        message: 'Invalid Parameters',
        error: [
          'quantity parameter was invalid. Try again'
        ]
      },
      status: :bad_request
  end
end
