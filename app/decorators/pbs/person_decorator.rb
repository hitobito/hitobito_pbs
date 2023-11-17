# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::PersonDecorator
  extend ActiveSupport::Concern

  included do

    def filtered_roles(group = nil, multiple_groups = false)
      filtered_functions(visible_roles.to_a, :group, group)
    end

    def roles_grouped(scope:)
      visible_roles.each_with_object(Hash.new { |h, k| h[k] = [] }) do |role, memo|
        memo[role.group] << role
      end
    end

  end

  private

    def layer_group_ids
      @layer_group_ids ||= current_user&.layer_group_ids ||
        [current_service_token&.layer_group_id].compact.presence ||
        Person.find(current_oauth_token.resource_owner_id)&.layer_group_ids
    end

    def visible_roles
      @visible_roles ||= roles.select do |role|
        layer_group_ids.include?(role.group.layer_group_id) || role.visible_from_above
      end
    end

end
