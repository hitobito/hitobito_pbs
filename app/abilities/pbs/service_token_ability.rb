# encoding: utf-8

#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ServiceTokenAbility
  extend ActiveSupport::Concern

  included do
    alias_method_chain :in_same_layer_or_below, :crisis
    alias_method_chain :in_same_layer, :crisis
  end

  private

  def in_same_layer_or_below_with_crisis
    in_same_layer_or_below_without_crisis && !crisis_ability?
  end

  def in_same_layer_with_crisis
    in_same_layer_without_crisis && !crisis_ability?
  end

  def crisis_ability?
    !is_a?(CrisisAbility)
  end

end
