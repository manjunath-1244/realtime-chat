Rails.application.routes.draw do
  devise_for :users
  resources :rooms, only: [:index, :show, :new, :create]
  root "rooms#index"

  resources :rooms do
    resources :messages, only: [:create, :edit, :update, :destroy] do
      member do
        patch :pin
      end
    end
  end
  resources :audit_logs, only: [:index]

  get "up" => "rails/health#show", as: :rails_health_check
end
