# frozen_string_literal: true

module Api
  module V1
    module Merchants
      class SearchController < ApplicationController
        def index
          render json: MerchantSerializer.new(Merchant.find_all(params[:name]))
        end
      end
    end
  end
end
