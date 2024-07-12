#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class HelpController < ApplicationController
  POWER_USER_ROLE_TYPES = %w[Group::Bund::PowerUser Group::Kantonalverband::PowerUser
    Group::Region::PowerUser Group::Abteilung::PowerUser].freeze

  skip_authorization_check only: [:index]

  def index
    @groups_and_power_users = current_user.groups.distinct.map do |group|
      [group, power_users_for_group_or_above(group)]
    end
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
end
