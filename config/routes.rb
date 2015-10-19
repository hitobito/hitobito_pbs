# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do

    resources :censuses, only: [:new, :create]
    get 'censuses' => 'censuses#new' # route required for language switch

    resources :groups do
      member do
        get 'pending_approvals' => 'groups#pending_approvals'

        scope module: 'census_evaluation' do
          get 'census/bund' => 'bund#index'
          get 'census/kantonalverband' => 'kantonalverband#index'
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
        end

        scope module: 'event' do
          resources :participations, only: [] do
            member do
              put :cancel_own
            end
          end
        end
      end

    end

    get 'list_all_camps' => 'event/lists#all_camps', as: :list_all_camps
    get 'list_kantonalverband_camps' => 'event/lists#kantonalverband_camps',
        as: :list_kantonalverband_camps
    get 'list_camps_in_canton' => 'event/lists#camps_in_canton', as: :list_camps_in_canton
    get 'list_camps_abroad' => 'event/lists#camps_abroad', as: :list_camps_abroad

  end

end
