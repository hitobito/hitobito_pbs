# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do

    resources :censuses, only: [:new, :create]
    get 'censuses' => 'censuses#new' # route required for language switch

    resources :groups do
      resources :crises, only: [:create, :update]

      member do
        get 'pending_approvals' => 'group/pending_approvals#index'
        get 'approved_approvals' => 'group/pending_approvals#approved'
        patch 'pending_approvals_role' => 'group/pending_approvals#update_role'

        scope module: 'census_evaluation' do
          get 'census/bund' => 'bund#index'
          get 'census/kantonalverband' => 'kantonalverband#index'
          get 'census/region' => 'region#index'
          get 'census/abteilung' => 'abteilung#index'

          post 'census/kantonalverband/remind' => 'kantonalverband#remind'
        end

        get 'population' => 'population#index'
      end

      resource :member_counts, only: [:create, :edit, :update, :destroy]

      get 'member_counts' => 'member_counts#edit' # route required for language switch

      resources :events, only: [] do # do not redefine events actions, only add new ones
        collection do
          get 'camp' => 'events#index', type: 'Event::Camp'
        end
        member do
          get 'camp_application' => 'events#show_camp_application'
          put 'camp_application' => 'events#create_camp_application'
          get 'attendances' => 'event/attendances#index'
          patch 'attendances' => 'event/attendances#update'
        end

        scope module: 'event' do
          resources :participations, only: [] do
            member do
              put :cancel_own
            end
            resources :approvals, only: [:new, :create, :edit, :update]
            get 'approvals' => 'approvals#new' # route required for language switch
          end
          resources :approvals, only: [:index]
          post 'send_confirmation_notifications', controller: 'qualifications',
              action: 'send_confirmation_notifications'
        end

        resources :subcamps, only: [:index]
      end

      get 'supercamps' => 'supercamps#available'
      get 'query_supercamps' => 'supercamps#query'
      post 'connect_supercamp' => 'supercamps#connect'
      patch 'connect_supercamp' => 'supercamps#connect'

    end

    get 'list_camps' => 'event/lists#camps', as: :list_camps
    get 'list_all_camps' => 'event/lists#all_camps', as: :list_all_camps
    get 'list_kantonalverband_camps' => 'event/lists#kantonalverband_camps',
        as: :list_kantonalverband_camps
    get 'list_camps_in_canton' => 'event/lists#camps_in_canton', as: :list_camps_in_canton
    get 'list_camps_abroad' => 'event/lists#camps_abroad', as: :list_camps_abroad

    resources :black_lists

    get 'help' => 'help#index'

  end

  namespace :group_health, defaults: {format: :json} do
    get :people
    get :roles
    get :groups
    get :courses
    get :camps
    get :participations
    get :qualifications
    get :qualification_kinds
    get :event_kinds
    get :role_types
    get :group_types
    get :participation_types
    get :j_s_kinds
    get :camp_states
    get :census_evaluations
  end

end
