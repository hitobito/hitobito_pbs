# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Application) do
      permission(:approve_applications).
        may(:approve, :reject).
        for_approvals_in_same_layer

      permission(:approve_applications).
        may(:show_priorities, :show_approval).
        for_approvals_in_hierarchy

      permission(:any).
        may(:show_approval).
        for_advised_or_participations_full_events

      permission(:layer_and_below_full).
        may(:show_approval).
        in_same_layer_or_below_or_different_prio
    end

    on(Event::Approval) do
      permission(:approve_applications).
        may(:create).
        for_approvals_in_same_layer
    end
  end

  def for_approvals_in_same_layer
    if primary_group && subject.next_open_approval
      approving_roles = subject.next_open_approval.roles
      user.roles.any? do |role|
        approving_roles.include?(role.class) &&
        layer_ids.include?(role.group_id)
      end
    end
  end

  def for_approvals_in_hierarchy
    if primary_group
      approving_roles = user.roles.select { |r| r.permissions.include?(:approve_applications) }
      contains_any?(layer_ids, approving_roles.collect(&:group_id))
    end
  end

  def primary_group
    participation.person.primary_group
  end

  def layer_ids
    primary_group.layer_hierarchy.collect(&:id)
  end

  def for_advised_or_participations_full_events
    participation.event.advisor_id == user.id ||
      for_participations_full_events
  end

end
