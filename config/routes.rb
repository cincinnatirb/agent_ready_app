Rails.application.routes.draw do
  root "parcels#index"

  resources :parcels do
    get :chat, on: :collection
    post :process_chat, on: :collection
    get :review, on: :member
    resources :structures
  end

  resources :chat, only: [:index]
  post "/chat/message", to: "chat#message", as: :chat_message
  post "/chat/clear", to: "chat#clear", as: :chat_clear

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
end
