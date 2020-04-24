#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::TokenAbility
  extend ActiveSupport::Concern

  included do
    alias_method_chain :define_token_abilities, :healthcheck
  end

  private

  def define_token_abilities_with_healthcheck
    define_token_abilities_without_healthcheck
    define_healthcheck_abilities if token.healthcheck?
  end

  def define_healthcheck_abilities
    can :show, HealthcheckController
  end
end
