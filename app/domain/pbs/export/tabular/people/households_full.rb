# encoding: utf-8

#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Export::Tabular::People
  class HouseholdsFull < Export::Tabular::People::Households

    def person_attributes
      super +
      [:correspondence_language, :kantonalverband_id,
       :id, :layer_group_id, :company_name, :company, :tags]
    end
  end
end
