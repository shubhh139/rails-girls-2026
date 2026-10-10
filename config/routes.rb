Rails.application.routes.draw do
<<<<<<< HEAD
  resource :donor_profile, only: [:new, :create, :edit, :update]

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
=======
  # Home page (UI_DESIGN.md screen 1)
  root "pages#home"

  # Every component class from UI_DESIGN.md, for reference while building
  get "styleguide" => "pages#styleguide"

  # Log in, log out and sign up (see ApplicationController)
  resource :session, only: [ :new, :create, :destroy ]
  resource :registration, only: [ :new, :create ]

  # Module routes. Nobody edits this file during the build.
  resource  :donor_profile, only: [ :new, :create, :edit, :update ]   # Module A
  resources :donors, only: [ :index ]                                   # Module B
  resources :blood_requests, only: [ :index, :show, :new, :create ] do  # Modules C and D
    resources :responses, only: [ :create ]                             # Module E
  end
>>>>>>> main

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
