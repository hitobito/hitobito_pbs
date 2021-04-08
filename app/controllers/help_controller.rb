#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class HelpController < ApplicationController

  POWER_USER_ROLE_TYPES = %w(Group::Bund::PowerUser Group::Kantonalverband::PowerUser
                             Group::Region::PowerUser Group::Abteilung::PowerUser).freeze

  skip_authorization_check only: [:index]

  def index
    @groups_and_power_users = current_user.groups.distinct.map do |group|
      [group, power_users_for_group_or_above(group)]
    end

    @groups_and_roles_that_see_me = groups_and_roles_that_see_me
  end

  private

  def groups
    @groups ||= Group.where(id: current_user.groups_hierarchy_ids).all
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
    group.roles.where(type: POWER_USER_ROLE_TYPES).pluck(:person_id)
  end

  def groups_and_roles_that_see_me
    groups_and_roles = {}
    Role::TypeList.new(Group.root_types.first).flatten.each do |role|
      all_groups.each do |group_id, group_name, group_type|
        next unless can_see_me?(role, group_id, group_type)

        groups_and_roles[group_id] ||= { name: group_name, roles: [] }
        groups_and_roles[group_id][:roles] << role.label
      end
    end
    groups_and_roles
  end

  def all_groups
    @all_groups ||= Group.order_by_type.pluck(:id, :name, :type)
  end

  def can_see_me?(role, group_id, group_type)
    return false if group_type != role.name.deconstantize

    test_person = Ability.new(Person.new(roles: [role.new(group_id: group_id)]))
    test_person.can?(:show_details, current_user)
  end

end
