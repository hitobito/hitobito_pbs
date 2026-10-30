#  Copyright (c) 2018-2026, hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::Export::Tabular::People
  class ParticipationsHouseholdsFull < HouseholdsFull
    def initialize(list, *args, **kwargs)
      super(people(list), *args, **kwargs)
    end

    def people(list)
      list.map(&:person)
    end
  end
end
