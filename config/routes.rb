Rails.application.routes.draw do
  root to: 'static#index'

  use_doorkeeper do
    skip_controllers :applications
  end

  devise_config = ActiveAdmin::Devise.config
  devise_config[:controllers][:omniauth_callbacks] = 'people/omniauth_callbacks'
  devise_for :people, devise_config

  ActiveAdmin.routes(self)
  namespace :admin do
    resources :people
    resources :addresses
    resources :advocacy_campaigns
    resources :answers
    resources :attendances
    resources :canvasses
    resources :canvassing_efforts
    resources :donations
    resources :email_addresses
    resources :email_shares
    resources :events
    resources :facebook_shares
    resources :forms
    resources :fundraising_pages
    resources :groups
    resources :memberships
    resources :outreaches
    resources :payments
    resources :petitions
    resources :phone_numbers
    resources :profiles
    resources :queries
    resources :questions
    resources :recipients
    resources :referrer_data
    resources :reminders
    resources :responses
    resources :scripts
    resources :script_questions
    resources :share_pages
    resources :signatures
    resources :submissions
    resources :targets
    resources :tickets
    resources :ticket_levels
    resources :twitter_shares
    resources :employer_addresses
    resources :event_addresses
    resources :personal_addresses

    #root to: "people#index"
  end


  #root to: "_site/index.html"

  resources :groups do
    get '/dashboard', to: 'dashboard#show', as: 'dashboard'

    resources :members do
      resources :events
      resources :tags, only: [:create, :destroy], controller: 'membership_tags'
    end
    resources :memberships, only: [:index]

    resources :affiliates

    resources :events do
      collection do
        resources :imports, only: [:new, :create] do
          collection do
            get :find
            get '/:remote_event_id/attendances', to: 'imports#attendances', as: 'attendances'
            post '/:remote_event_id/attendances', to: 'imports#create_facebook_attendance', as: 'create_attendance'
            delete '/:remote_event_id/attendances', to: 'imports#delete_facebook_attendance', as: 'delete_attendance'
          end
        end
      end

      resources :attendances
    end

    resources :tags, only: [:create, :destroy], controller: 'group_tags'
  end

  resources :dashboard, only: [:index]

  resources :memberships, only: [] do
    resources :tags, only: [:create, :destroy], controller: 'membership_tags'
  end

  resources :profile, only: [:index]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      get '/', to: 'entry_point#show'
      resources :people
      resources :events, only: [] do
        resources :attendances
      end
    end
  end

  #mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/queries"
  resources :queries
  resource :sha, only: :show
  resources :zipcodes, only: :show
  get '/.well-known/acme-challenge/:id', to: 'wellknown#show'
end
