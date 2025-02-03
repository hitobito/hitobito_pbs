#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe Person::AddRequest::Approver::Event do
  let(:person) { Fabricate(Group::Pfadi::Pfadi.name, group: groups(:kcbr)).person }
  let(:requester) { Fabricate(Group::Pfadi::Einheitsleitung.name, group: groups(:kcbr)).person }

  let(:user) { Fabricate(Group::Pfadi::Pfadi.name, group: groups(:kcbr)).person }

  subject { Person::AddRequest::Approver.for(request, user) }

  context "Camp" do
    let(:event) { events(:tsueri_supercamp).tap { |e| e.update!(j_s_kind: "j_s_child") } }

    let(:request) do
      Person::AddRequest::Event.create!(
        person: person,
        requester: requester,
        body: event,
        role_type: Event::Camp::Role::Participant.sti_name
      )
    end

    context "#approve" do
      it "creates a new participation" do
        expect(event).to be_j_s_data_sharing_acceptance_required

        expect do
          subject.approve
        end.to change { Event::Participation.count }.by(1)

        p = person.event_participations.first

        expect(p).to be_active
        expect(p.roles.count).to eq(1)
        expect(p.roles.first).to be_a(Event::Role::Participant)
        expect(p.application).to be_nil
      end
    end
  end
end
