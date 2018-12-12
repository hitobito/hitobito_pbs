#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CrisisAbility < Ability

  attr_reader :crises

  def initialize(user, crises)
    super(user)
    @crises = crises
    define_crises_abilities
  end

  private

  def define_crises_abilities
    can :index_people, Group do |g|
      involved_groups.include?(g)
    end

    can :show, Person do |p|
      Role.where(group: involved_groups, person: p).present?
    end
  end

  def involved_groups
    Group.where(id: crises.pluck(:group_id)).
      map(&:self_and_descendants).
      flatten.
      uniq
  end

end
