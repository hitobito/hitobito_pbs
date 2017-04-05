# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalAbility < AbilityDsl::Base

  on(Event::Approval) do
    permission(:approve_applications).
      may(:create).
      for_approvals_in_same_layer
  end

  def for_approvals_in_same_layer
    if primary_group && subject.status.nil?
      approving_roles = subject.roles
      user.roles.any? do |role|
        approving_roles.include?(role.class) &&
          layer_ids.include?(role.group_id)
      end
    end
  end

  def primary_group
    subject.approvee.primary_group
  end

  def layer_ids
    primary_group.layer_hierarchy.collect(&:id)
  end

end
