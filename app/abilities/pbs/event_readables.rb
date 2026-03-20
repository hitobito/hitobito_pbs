# frozen_string_literal: true

#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::EventReadables
  extend ActiveSupport::Concern

  def accessible_conditions
    super.tap do |condition|
      part_of_krisenteam_condition(condition)
    end
  end

  def part_of_krisenteam_condition(condition)
    cantons = krisenteam_cantons
    condition.or("events.canton IN (?)", cantons) if cantons.present?
  end

  def krisenteam_cantons
    user.roles
      .select { |role| Pbs::EventAbility::CAMP_KRISENTEAM_ROLES.any? { |type| role.is_a?(type) } }
      .map(&:group)
      .uniq
      .flat_map(&:cantons)
      .uniq
  end

  def participating_condition(condition)
    subquery = participations
      .joins(:event)
      .joins("INNER JOIN events AS descendants ON " \
        "descendants.lft >= events.lft AND descendants.rgt <= events.rgt")
      .select("descendants.id")

    condition.or("events.id IN (#{subquery.to_sql})")
  end
end
