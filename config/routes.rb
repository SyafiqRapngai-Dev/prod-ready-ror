Rails.application.routes.draw do
  devise_for :users

  root "dashboard#index"

  resources :organizations, param: :slug do
    resources :memberships, only: [ :index, :new, :create, :destroy ]

    resources :projects, param: :key do
      resources :project_members, as: :members, only: [ :index, :new, :create, :update, :destroy ]

      resources :boards, only: [ :show, :new, :create ] do
        resources :columns, only: [ :new, :create, :update, :destroy ] do
          member do
            patch :move
          end
        end
      end

      resources :tasks do
        member do
          patch :move
        end
        resources :comments, only: [ :create, :update, :destroy ]
      end

      resources :labels
    end
  end

  resources :notifications, only: [ :index ] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end

  get "search", to: "search#index"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
