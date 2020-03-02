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

require 'spec_helper'

describe Geolocation do

  it 'has a string representation' do
    subject = Fabricate(:geolocation)
    expect(subject.to_s).to eq("(#{subject.lat}, #{subject.long})")
  end

  it 'has a valid WGS84 format' do
    expect { Fabricate(:geolocation, lat: 'abc', long: 'abc') }.to raise_error(ActiveRecord::RecordInvalid)
    expect { Fabricate(:geolocation, lat: '47.0', long: '200.0') }.to raise_error(ActiveRecord::RecordInvalid)
    expect { Fabricate(:geolocation, lat: '99.0', long: '5.5') }.to raise_error(ActiveRecord::RecordInvalid)
    expect { Fabricate(:geolocation, lat: '47', long: '8.0') }.to raise_error(ActiveRecord::RecordInvalid)
    expect { Fabricate(:geolocation, lat: '45.1234567', long: '123.33') }.to raise_error(ActiveRecord::RecordInvalid)
  end

end
