#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::GroupSerializer
  extend ActiveSupport::Concern

  included do
    extension(:attrs) do |_|
      map_properties(*item.used_attributes(:pbs_shortname, :website, :bank_account, :pta, :vkp,
        :pbs_material_insurance, :description,
        :gender, :try_out_day_at))
      item.used?(:geolocations) do
        entities :geolocations, item.geolocations, GeolocationSerializer
      end
    end
  end
end
