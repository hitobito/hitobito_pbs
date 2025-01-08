#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: geolocations
#
#  id                     :integer          not null, primary key
#  lat                    :string
#  long                   :string
#  geolocatable_id        :integer          not null
#  geolocatable_type      :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

Fabricator(:geolocation) do
  lat { (46.0 + 1.5 * rand).round(3).to_s }
  long { (6.0 + 4 * rand).round(3).to_s }
end
