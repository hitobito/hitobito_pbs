#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Person::FamilyMemberFinder
  attr_reader :person

  def initialize(person)
    @person = person
  end

    def siblings_in_layer(group, kind: :sibling)
      Role.joins(person: :family_members)
          .where(group: group.groups_in_same_layer, 
                 person: { family_members: { kind: kind, other: person } })
    end

end
