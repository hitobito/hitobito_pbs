# encoding: utf-8

#  Copyright (c) 2020, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::PersonDecorator
  extend ActiveSupport::Concern

  included do
    alias_method_chain :filtered_roles, :visibility_check
    alias_method_chain :roles_grouped, :visibility_check
  end

  private
    def filtered_roles_with_visibility_check(group = nil)
      filtered_functions(visible_roles.to_a, :group, group)
    end

    def roles_grouped_with_visibility_check
      visible_roles.each_with_object(Hash.new { |h, k| h[k] = [] }) do |role, memo|
        memo[role.group] << role
      end
    end

    def layer_group_ids
      @layer_group_ids ||= current_user.layer_group_ids
    end

    def visible_roles
      @visible_roles ||= roles.select do |role|
        layer_group_ids.include?(role.group.layer_group_id) || role.visible_from_above
      end
    end

end
