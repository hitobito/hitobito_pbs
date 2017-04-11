# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Csv::People
  # adds social_accounts and company related attributes
  class PeopleFull < PeopleAddress

    def person_attributes
      Person.column_names.collect(&:to_sym) -
        Person::INTERNAL_ATTRS -
        [:picture] +
        [:primary_group_id, :id, :roles]
    end

  end
end
