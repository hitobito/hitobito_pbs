# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Participation) do
      permission(:any).may(:cancel).for_participations_full_events
      permission(:group_full).may(:cancel, :reject).in_same_group
      permission(:layer_full).may(:cancel, :reject).in_same_layer
      permission(:layer_and_below_full).may(:cancel, :reject).in_same_layer

      permission(:group_full).may(:create_tentative).person_in_same_group
      permission(:layer_full).may(:create_tentative).person_in_same_layer
      permission(:layer_and_below_full).may(:create_tentative).person_in_same_layer_or_visible_below
      general(:create_tentative).event_tentative_and_person_in_tentative_group
    end
  end

  def person_in_same_group
    person ? permission_in_groups?(person.groups.collect(&:id)) : true
  end

  def person_in_same_layer
    person ? permission_in_layers?(person.groups.collect(&:layer_group_id)) : true
  end

  def person_in_same_layer_or_visible_below
    person ? ( person_in_same_layer || visible_below) : true
  end

  def event_tentative_and_person_in_tentative_group
    event.tentative_application_possible? && permission_in_groups?(event.tentative_group_ids)
  end

  private

  def event
    participation.event
  end

  def person
    participation.person
  end

  def visible_below
    permission_in_layers?(participation.person.above_groups_where_visible_from.collect(&:id))
  end

end
