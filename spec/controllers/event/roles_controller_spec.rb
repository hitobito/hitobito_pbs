#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::RolesController do
  let(:group) { event.groups.first }

  before { sign_in(people(:bulei)) }

  context "POST create" do
    context "simple" do
      let(:event) { events(:top_event) }

      it "creates helper in state nil" do
        expect do
          post :create,
            params: {
              group_id: group.id,
              event_id: event.id,
              event_role: {
                type: Event::Role::Cook.sti_name,
                person_id: people(:al_berchtold).id,
                participation_attributes: {
                  j_s_data_sharing_accepted: ["0", "1"]
                }
              }
            }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to be_nil
      end
    end

    context "course" do
      let(:event) { events(:top_course) }

      it "creates helper in state assigned" do
        expect do
          post :create,
            params: {
              group_id: group.id,
              event_id: event.id,
              event_role: {
                type: Event::Role::Cook.sti_name,
                person_id: people(:al_berchtold).id,
                participation_attributes: {
                  j_s_data_sharing_accepted: ["0", "1"]
                }
              }
            }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq "assigned"
      end
    end

    context "campy course" do
      let(:event) { Fabricate(:course, kind: event_kinds(:fut)) }

      it "creates camp role" do
        expect do
          post :create,
            params: {
              group_id: group.id,
              event_id: event.id,
              event_role: {
                type: Event::Camp::Role::LeaderSnowSecurity.sti_name,
                person_id: people(:al_berchtold).id,
                participation_attributes: {
                  j_s_data_sharing_accepted: ["0", "1"]
                }
              }
            }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role).to be_kind_of(Event::Camp::Role::LeaderSnowSecurity)
        expect(role.participation.state).to eq "assigned"
      end
    end

    context "camp" do
      let(:event) { events(:schekka_camp) }

      it "creates helper in state assigned" do
        expect do
          post :create,
            params: {
              group_id: group.id,
              event_id: event.id,
              event_role: {
                type: Event::Camp::Role::Helper.sti_name,
                person_id: people(:al_berchtold).id,
                participation_attributes: {
                  j_s_data_sharing_accepted: ["0", "1"]
                }
              }
            }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq "assigned"
      end

      it "creates participant in state assigned" do
        expect do
          post :create,
            params: {
              group_id: group.id,
              event_id: event.id,
              event_role: {
                type: Event::Camp::Role::Participant.sti_name,
                person_id: people(:al_berchtold).id,
                participation_attributes: {
                  j_s_data_sharing_accepted: ["0", "1"]
                }
              }
            }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq "assigned"
      end

      it "creates assistant leader role for existing participant" do
        person = event.participations.first.person
        expect do
          post :create,
            params: {
              group_id: group.id,
              event_id: event.id,
              event_role: {
                type: Event::Camp::Role::AssistantLeader.sti_name,
                person_id: person.id,
                participation_attributes: {
                  j_s_data_sharing_accepted: ["0", "1"]
                }
              }
            }
        end.to change { Event::Role.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq "assigned"
      end
    end
  end
end
