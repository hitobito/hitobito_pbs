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

class Geolocation < ActiveRecord::Base

  belongs_to :geolocatable, polymorphic: true

  validates :lat, format: { with: %r{\A-?([1-8]?[0-9]
    \.{1}\d{1,6}\z|90\.{1}0{1,6}\z)}x }
  validates :long, format: { with: %r{\A-?((([1]?[0-7][0-9]|[1-9]?[0-9])
    \.{1}\d{1,6}\z)|[1]?[1-8][0]\.{1}0{1,6}\z)}x }

  validates_by_schema

  def to_s
    "(#{lat}, #{long})"
  end

end
