# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Rails.application.routes.draw do

  resources :censuses, only: [:new, :create]

  resources :groups do
    member do
      scope module: 'census_evaluation' do
        get 'census/bund' => 'bund#index'
        get 'census/kantonalverband' => 'kantonalverband#index'
        get 'census/abteilung' => 'abteilung#index'

        post 'census/kantonalverband/remind' => 'kantonalverband#remind'
      end

      get 'population' => 'population#index'
    end

    resource :member_counts, only: [:create, :edit, :update, :destroy]
  end

end
