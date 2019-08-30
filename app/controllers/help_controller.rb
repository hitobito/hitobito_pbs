#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class HelpController < ApplicationController

  skip_authorization_check only: [:index]

  def index
    @groups = groups_of_current_user.map do |group|
      [group, power_users_for_group_or_above(group)]
    end
  end

  private

  def groups_of_current_user
    current_user.roles.map do |role|
      groups.find { |group| group.id == role.group_id }
    end.uniq
  end

  def groups
    @groups ||= Group.where(id: current_user.groups_hierarchy_ids).includes(:roles).all
  end

  def power_users_for_group_or_above(group)
    Person.where(id: power_user_ids_for_group_or_above(group))
  end

  def power_user_ids_for_group_or_above(group)
    power_user_ids = power_user_ids_for_group(group)
    return power_user_ids unless power_user_ids.empty?
    return [] if group.parent_id.nil?

    parent_group = groups.find { |g| g.id == group.parent_id }
    power_user_ids_for_group_or_above(parent_group)
  end

  def power_user_ids_for_group(group)
    group.roles.select do |role|
      power_user_role_types.include? role.type
    end.map(&:person_id)
  end

  def power_user_role_types
    @power_user_role_types ||= Role.descendants.select do |role|
      role.name.ends_with? '::Adressverwaltung'
    end.map(&:name)
  end

end
