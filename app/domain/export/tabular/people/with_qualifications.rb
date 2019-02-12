#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Tabular::People
  class WithQualifications < PeopleFull
    self.row_class = Export::Tabular::People::WithQualificationRow

    def person_attributes
      [
        :id, :first_name, :nickname,
        :address, :town, :zip_code, :country,
        :gender, :birthday,
        :layer_group, :layer_group_id,
        :entry_date,
        :roles,
        :kantonalverband_id,
        :kantonalverband_name,
      ]
    end

    def association_attributes
      qualification_kind_labels
    end

  end
end
