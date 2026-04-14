#  Copyright (c) 2020-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::TokenAbility
  extend ActiveSupport::Concern

  def initialize(token)
    super

    if token.group_health? && token.layer.instance_of?(Group::Bund)
      can :show, GroupHealthController
    end
    if token.census_evaluations? && token.layer.instance_of?(Group::Bund)
      can :census_evaluations, GroupHealthController
    end
  end
end
