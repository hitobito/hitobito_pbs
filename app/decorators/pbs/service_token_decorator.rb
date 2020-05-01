# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::ServiceTokenDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :abilities, :group_health
  end

  def abilities_with_group_health
    kinds = [:people, :people_below, :events, :groups, :invoices,
      :event_participations, :group_health]

    safe_join(kinds.map do |ability|
      ability_description(ability, :read) if public_send(ability)
    end.compact, h.tag(:br))
  end
end
