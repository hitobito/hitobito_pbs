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
        get 'pending_approvals' => 'groups#list_pending_approvals'

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
        member do
          get 'approvals' => 'events#list_completed_approvals'
        end
      end
    end


  end

end
