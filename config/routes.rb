Rails.application.routes.draw do
  get 'messages/create'
  devise_for :users
  resources :rooms, only: [:index, :show, :new, :create]
  root "rooms#index"

  resources :rooms do
    resources :messages, only: [:create, :destroy]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
