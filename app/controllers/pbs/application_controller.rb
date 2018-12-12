#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ApplicationController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :current_ability, :crisis
  end

  def current_ability_with_crisis
    if active_crises
      @current_ability ||= CrisisAbility.new(current_user, active_crises)
    else
      current_ability_without_crisis
    end
  end

  private

  def active_crises
    @active_crisis ||= Crisis.active.where(creator: current_user)
  end
end
