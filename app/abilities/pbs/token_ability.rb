#  Copyright (c) 2020-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::TokenAbility
  extend ActiveSupport::Concern

  def initialize(token)
    super

    can :show, GroupHealthController if token.group_health?
    can :census_evaluations, GroupHealthController if token.census_evaluations?
  end
end
