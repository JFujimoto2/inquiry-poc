Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  namespace :admin do
    root "dashboard#index"
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

  resources :inquiries, only: %i[new create] do
    collection do
      get :thank_you
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "inquiries#new"
end
