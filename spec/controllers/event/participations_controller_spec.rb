#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::ParticipationsController do
  let(:group) { course.groups.first }
  let(:course) { Fabricate(:pbs_course, groups: [groups(:bund)]) }

  before { sign_in(people(:bulei)) }

  context "GET#show" do
    let(:event) { events(:top_event) }
    let(:camp) { events(:bund_camp) }
    let!(:participant) { Fabricate(:person) }

    before do
      [event, camp, course].each { |e| Fabricate(:pbs_participation, person: participant, event: e) }
    end

    [:event, :camp, :course].each do |kind|
      it "works for #{kind}" do
        instance = send(kind)
        get :show,
          params: {
            group_id: group.id,
            event_id: instance.id,
            id: instance.participations.first.id
          }
        expect(response).to have_http_status(:ok)
      end
    end

    context "if the participant lives in a household" do
      render_views

      before do
        participant.update(household_key: "1111-2222-3333")
        Fabricate(:person, household_key: participant.household_key)
      end

      it "it still works" do
        get :show,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: course.participations.last.id
          }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "GET#new" do
    it "informs about email sent to participant" do
      get :new,
        params: {
          group_id: group.id,
          event_id: course.id,
          event_participation: {person_id: people(:child).id}
        }
      expect(flash[:notice]).to be_present
    end
  end

  context "POST#create" do
    let(:participation) { assigns(:participation).reload }

    it "creates confirmation job when creating for other user" do
      expect do
        post :create,
          params: {
            group_id: group.id,
            event_id: course.id,
            event_participation: {person_id: people(:child).id, j_s_data_sharing_accepted: true}
          }
        expect(participation).to be_valid
      end.to change { Delayed::Job.count }.by(1)
      expect(flash[:notice]).not_to include "Für die definitive Anmeldung musst du diese Seite über <i>Drucken</i> ausdrucken, "
    end

    it "creates participation for camp" do
      camp = Fabricate(:pbs_camp, paper_application_required: true)
      post :create, params: {group_id: group.id, event_id: camp.id, event_participation: {j_s_data_sharing_accepted: true}}

      participation = assigns(:participation)
      expect(participation).to be_valid
      expect(participation).to be_active
      expect(participation.state).to eq("applied_electronically")
    end

    it "always requires approval for pbs courses" do
      course.update!(requires_approval: false, state: "application_open", priorization: false)

      post :create,
        params: {
          group_id: group.id,
          event_id: course.id,
          event_role: {type: Event::Course::Role::Participant.to_s}
        }

      participation = course.participations.first
      expect(participation.state).to eq("applied")
      expect(participation).not_to be_active
    end
  end

  context "POST cancel" do
    let(:participation) { Fabricate(:pbs_participation, event: course, state: "assigned") }

    it "cancels participation" do
      expect do
        post :cancel,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id,
            event_participation: {canceled_at: Date.today}
          }
      end.to change { Delayed::Job.count }.by(1)
      expect(flash[:notice]).to be_present
      participation.reload
      expect(participation.canceled_at).to eq Date.today
      expect(participation.state).to eq "canceled"
      expect(participation.active).to eq false
      expect(Delayed::Job.last.payload_object.instance_variable_get(:@previous_state))
        .to eq("assigned")
    end

    it "does nothing if participation is already canceled" do
      participation.update!(state: "canceled", canceled_at: Date.today)
      expect do
        post :cancel,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id,
            event_participation: {canceled_at: Date.today}
          }
      end.to change { Delayed::Job.count }.by(0)
    end
  end

  context "POST reject" do
    render_views

    let(:participation) { Fabricate(:pbs_participation, event: course, state: "assigned") }
    let(:dom) { Capybara::Node::Simple.new(response.body) }

    it "rejects participation with mailto link if email present" do
      expect do
        post :reject,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id
          }
      end.to change { Delayed::Job.count }.by(1)
      participation.reload
      expect(participation.state).to eq "rejected"
      expect(participation.active).to eq false
      expect(Delayed::Job.last.payload_object.instance_variable_get(:@previous_state))
        .to eq("assigned")
      expect(flash[:notice]).to include "Teilnehmer*in informieren"
      expect(flash[:notice]).to include "mailto:#{participation.person.email}"
      expect(flash[:notice]).to include "cc=bulei%40hitobito.example.com"
    end

    it "rejects participation without mailto link if email missing" do
      participation.person.update(email: nil)
      post :reject,
        params: {
          group_id: group.id,
          event_id: course.id,
          id: participation.id
        }
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).not_to include "Teilnehmer informieren"
      participation.reload
      expect(participation.state).to eq "rejected"
      expect(participation.active).to eq false
    end

    it "does nothing if participation is already rejected" do
      participation.update!(state: "rejected")
      expect do
        post :reject,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id
          }
      end.to change { Delayed::Job.count }.by(0)
    end
  end

  context "PUT update" do
    let(:participation) { Fabricate(:pbs_participation, event: course) }

    context "camp" do
      let(:course) { events(:schekka_camp) }

      it "updates state" do
        put :update,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id,
            event_participation: {state: "absent"}
          }
        expect(flash[:notice]).to be_present
        participation.reload
        expect(participation.state).to eq "absent"
      end
    end

    context "course" do
      it "does not update state" do
        state = participation.state
        put :update,
          params: {
            group_id: group.id,
            event_id: course.id,
            id: participation.id,
            event_participation: {state: "cancelled"}
          }
        expect(flash[:notice]).to be_present
        participation.reload
        expect(participation.state).to eq state
      end
    end
  end

  context "PUT cancel_own" do
    let(:camp) { events(:schekka_camp) }
    let(:participation) { Fabricate(:pbs_participation, event: camp) }

    it "updates state and enqueues job" do
      camp.update!(participants_can_cancel: true, state: "confirmed")

      expect do
        put :cancel_own,
          params: {
            group_id: camp.groups.first.id,
            event_id: camp.id,
            id: participation.id
          }
      end.to change { Delayed::Job.count }.by(1)

      expect(flash[:notice]).to be_present
      participation.reload
      expect(participation.state).to eq("canceled")
    end
  end
end
