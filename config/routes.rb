Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :admin do
    root "dashboard#index"
    resources :customers
    resources :reservations do
      member do
        patch :transition
      end
    end
    resources :inquiries, only: %i[index show]
    resources :change_requests, only: %i[index show] do
      member do
        patch :respond
      end
    end
    resources :facilities
    resources :calendar_types do
      collection do
        post :bulk_create
      end
    end
    resources :price_masters
    resources :email_templates do
      member do
        get :preview
      end
    end
  end

  namespace :mypage do
    root "dashboard#index"
    resource :session, controller: "customer_sessions", only: %i[new create destroy] do
      get :verify, on: :collection
    end
    resources :reservations, only: %i[show] do
      resources :change_requests, only: %i[new create]
    end
  end

  resources :inquiries, only: %i[new create] do
    collection do
      get :thank_you
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "inquiries#new"
end
