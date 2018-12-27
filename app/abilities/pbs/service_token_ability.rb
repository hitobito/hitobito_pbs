# encoding: utf-8

#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ServiceTokenAbility
  extend ActiveSupport::Concern

  included do
    on(ServiceToken) do
      permission(:layer_and_below_full).
        may(:create, :show, :edit, :update, :destroy).
        none

      permission(:layer_full).
        may(:create, :show, :edit, :update, :destroy).
        none
    end
  end
end
