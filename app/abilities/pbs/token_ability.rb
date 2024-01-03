#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::TokenAbility
  extend ActiveSupport::Concern

  included do
    alias_method_chain :define_token_abilities, :group_health
    alias_method_chain :define_token_abilities, :census_evaluations
    alias_method_chain :define_event_abilities, :camps
  end

  private

  def define_token_abilities_with_group_health
    define_token_abilities_without_group_health
    define_group_health_abilities if token.group_health?
  end

  def define_token_abilities_with_census_evaluations
    define_token_abilities_without_census_evaluations
    define_census_evaluations_abilities if token.census_evaluations?
  end

  def define_group_health_abilities
    can :show, GroupHealthController
  end

  def define_census_evaluations_abilities
    can :census_evaluations, GroupHealthController
  end

  def define_event_abilities_with_camps
    define_event_abilities_without_camps

    can :'index_event/camps', Group do |g|
      token_layer_and_below.include?(g)
    end
  end
end
