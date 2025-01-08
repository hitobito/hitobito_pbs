#  Copyright (c) 2019, Pfadibewegung Schweiz This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Pbs::GroupSerializer do
  let(:group) { groups(:patria).decorate }
  let(:controller) { double.as_null_object }

  let(:serializer) { GroupSerializer.new(group, controller: controller) }
  let(:hash) { serializer.to_hash }

  subject { hash[:groups].first }

  it "serializes PBS group finder fields" do
    group.update!(gender: "m", try_out_day_at: "2019-03-23", website: "https://pfadi.ch")

    expect(subject["gender"]).to eq("m")
    expect(subject["try_out_day_at"]).to eq(Date.parse("2019-03-23"))
    expect(subject["website"]).to eq("https://pfadi.ch")
  end

  it "serializes group's geolocations" do
    g1 = Fabricate(Geolocation.name.downcase.to_sym, geolocatable: group)
    g2 = Fabricate(Geolocation.name.downcase.to_sym, geolocatable: group)

    links = subject[:links]
    expect(links[:geolocations]).to contain_exactly(g1.id.to_s, g2.id.to_s)
    linked = hash[:linked]
    expect(linked["geolocations"].size).to eq(2)
    expect(linked["geolocations"]).to include(include({id: g1.id.to_s, lat: g1.lat.to_s, long: g1.long.to_s}))
    expect(linked["geolocations"]).to include(include({id: g2.id.to_s, lat: g2.lat.to_s, long: g2.long.to_s}))
  end

  it "does not include group finder fields in group types other than Abteilung" do
    canton = groups(:be).decorate
    canton.update!(gender: "m", try_out_day_at: "2019-03-23", website: "https://pfadibern.ch")
    Fabricate(Geolocation.name.downcase.to_sym, geolocatable: canton)
    canton_serializer = GroupSerializer.new(canton, controller: controller)
    canton_hash = canton_serializer.to_hash
    canton_subject = canton_hash[:groups].first

    expect(canton_subject).not_to have_key("gender")
    expect(canton_subject).not_to have_key("try_out_day_at")
    expect(canton_subject["website"]).to eq("https://pfadibern.ch")
    expect(canton_subject).not_to have_key(:geolocations)
    expect(hash[:linked]).not_to have_key("geolocations")
  end
end
