Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/merchants/find_all', to: 'merchants#find_all'
      get '/merchants/most_items', to: 'merchants#most_items_sold'
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index]
      end
      
      get '/items/find', to: 'items#find'
      resources :items do
        get '/merchant', to: 'merchants#show'
      end

      get '/revenue/merchants', to: 'revenue#merchants_with_most_revenue'
      get '/revenue/merchants/:id', to: 'revenue#merchant_revenue'
      get '/revenue/items', to: 'revenue#items_with_most_revenue'
      get '/revenue/unshipped', to: 'revenue#unshipped_invoices'
    end
  end
end
