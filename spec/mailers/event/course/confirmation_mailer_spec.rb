#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::Course::ConfirmationMailer do
  let(:participation) { event_participations(:top_participant) }
  let(:mail) { Event::Course::ConfirmationMailer.notify(participation) }

  context "headers" do
    subject { mail }

    its(:subject) { is_expected.to eq "Kursbestätigung verfügbar" }
    its(:to) { is_expected.to eq ["al.schekka@hitobito.example.com"] }
    its(:from) { is_expected.to eq ["noreply@localhost"] }
  end

  context "body" do
    subject { mail.body }

    it "renders placeholders" do
      is_expected.to match(/Liebe\*r Torben/)
      is_expected.to match(/Für den bestandenen Kurs "Top Course" kann jetzt hier eine Bestätigung/)
      is_expected.to match(Regexp.new("/groups/#{participation.event.groups.first.id}" \
                                      "/events/#{participation.event.id}" \
                                      "/participations/#{participation.id}"))
    end
  end
end
