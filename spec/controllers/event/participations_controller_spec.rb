# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationsController do

  let(:group) { course.groups.first }
  let(:course) { Fabricate(:pbs_course, groups: [groups(:bund)]) }

  before { sign_in(people(:bulei)) }

  context 'GET#index.csv' do
    it 'contains kantonalverband' do
      get :index, group_id: group.id, event_id: course.id, format: :csv
      expect(response.body.lines.first).to match(/Kantonalverband/)
    end
  end

  context 'GET#new' do
    it 'informs about email sent to participant' do
      get :new,
          group_id: group.id,
          event_id: course.id,
          event_participation: { person_id: people(:child).id }
      expect(flash[:notice]).to be_present
    end
  end

  context 'POST#create' do
    let(:participation) { assigns(:participation).reload }

    it 'creates confirmation job when creating for other user' do
      expect do
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: people(:child).id }
        expect(participation).to be_valid
      end.to change { Delayed::Job.count }.by(1)
      expect(flash[:notice]).not_to include 'Für die definitive Anmeldung musst du diese Seite über <i>Drucken</i> ausdrucken, '
    end

  end

  context 'POST cancel' do

    let(:participation) { Fabricate(:pbs_participation, event: course) }

    it 'cancels participation' do
      expect do
        post :cancel,
             group_id: group.id,
             event_id: course.id,
             id: participation.id,
             event_participation: { canceled_at: Date.today }
      end.to change { Delayed::Job.count }.by(1)
      expect(flash[:notice]).to be_present
      participation.reload
      expect(participation.canceled_at).to eq Date.today
      expect(participation.state).to eq 'canceled'
      expect(participation.active).to eq false
    end

  end

  context 'POST reject' do
    render_views

    let(:participation) { Fabricate(:pbs_participation, event: course) }
    let(:dom) { Capybara::Node::Simple.new(response.body) }

    it 'rejects participation with mailto link if email present' do
      post :reject,
        group_id: group.id,
        event_id: course.id,
        id: participation.id
      participation.reload
      expect(participation.state).to eq 'rejected'
      expect(participation.active).to eq false
      expect(flash[:notice]).to include "Teilnehmer informieren"
      expect(flash[:notice]).to include "mailto:#{participation.person.email}"
      expect(flash[:notice]).to include "cc=bulei%40hitobito.example.com"
    end

    it 'rejects participation without mailto link if email missing' do
      participation.person.update(email: nil)
      post :reject,
        group_id: group.id,
        event_id: course.id,
        id: participation.id
      expect(flash[:notice]).to be_present
      expect(flash[:notice]).not_to include "Teilnehmer informieren"
      participation.reload
      expect(participation.state).to eq 'rejected'
      expect(participation.active).to eq false
    end
  end

  context 'PUT update' do
    let(:participation) { Fabricate(:pbs_participation, event: course) }

    context 'camp' do
      let(:course) { events(:schekka_camp) }

      it 'updates state' do
        put :update,
            group_id: group.id,
            event_id: course.id,
            id: participation.id,
            event_participation: { state: 'absent' }
        expect(flash[:notice]).to be_present
        participation.reload
        expect(participation.state).to eq 'absent'
      end
    end

    context 'course' do
      it 'does not update state' do
        state = participation.state
        put :update,
            group_id: group.id,
            event_id: course.id,
            id: participation.id,
            event_participation: { state: 'cancelled' }
        expect(flash[:notice]).to be_present
        participation.reload
        expect(participation.state).to eq state
      end
    end
  end

  context 'PUT cancel_own' do
    let(:camp) { events(:schekka_camp) }
    let(:participation) { Fabricate(:pbs_participation, event: camp) }

    it 'updates state and enqueues job' do
      camp.update!(participants_can_cancel: true, state: 'confirmed')

      expect do
        put :cancel_own,
            group_id: camp.groups.first.id,
            event_id: camp.id,
            id: participation.id
      end.to change { Delayed::Job.count }.by(1)

      expect(flash[:notice]).to be_present
      participation.reload
      expect(participation.state).to eq('canceled')
    end
  end

end
