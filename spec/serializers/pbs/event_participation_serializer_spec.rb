#  Copyright (c) 2019, Pfadibewegung Schweiz This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe EventParticipationSerializer do
  let(:controller) { double.as_null_object }
  let(:participation) { event_participations(:top_leader) }
  let(:serializer) { EventParticipationSerializer.new(participation, controller) }
  let(:hash) { serializer.to_hash.with_indifferent_access }
  let(:number) { "+41 75 000 00 00" }

  subject { hash[:event_participations].first }

  it "includes phone numbers" do
    participation.person.phone_numbers.create(number: number, public: true, translated_label: "Natel")

    expect(subject[:phone_numbers]).to eq([{"number" => number, "translated_label" => "Natel"}])
  end
end
