# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationAbility
  extend ActiveSupport::Concern
  include AbilityDsl::Constraints::Event::Participation

  included do
    on(Event::Application) do
      permission(:approve_applications).may(:approve, :reject).for_approvals_in_same_layer
      permission(:approve_applications).may(:show_approvals).for_approvals_in_hierarchy

      permission(:any).may(:show_approvals).for_participations_full_events
      permission(:group_full).may(:show_approvals).in_same_group
      permission(:group_and_below_full).may(:show_approvals).in_same_group_or_below
      permission(:layer_full).may(:show_approvals).in_same_layer_or_different_prio
      permission(:layer_and_below_full).
        may(:show_approvals).
        in_same_layer_or_below_or_different_prio
    end
  end

  def for_approvals_in_same_layer
    if primary_group && next_open_approval
      approving_roles = next_open_approval.roles
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

  delegate :next_open_approval, to: :subject

  def primary_group
    participation.person.primary_group
  end

  def layer_ids
    primary_group.layer_hierarchy.collect(&:id)
  end

  delegate :participation, to: :subject

end
