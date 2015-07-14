# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ApplicationAbility
  extend ActiveSupport::Concern

  included do
    on(Event::Application) do
      permission(:approve_applications).may(:approve, :reject).for_approvals_in_layer
    end
  end

  def for_approvals_in_layer
    if subject.next_open_approval && subject.participation.person.primary_group
      approving_roles = subject.next_open_approval.roles
      layer_ids = subject.participation.person.primary_group.layer_hierarchy.collect(&:id)
      user.roles.any? { |role| approving_roles.include?(role.class) && layer_ids.include?(role.group_id) }
    end
  end

end
