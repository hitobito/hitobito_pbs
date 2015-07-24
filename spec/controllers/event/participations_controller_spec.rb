# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationsController do

  let(:group) { course.groups.first }
  let(:course) { Fabricate(:pbs_course, groups: [groups(:bund)]) }
  let(:participation) { assigns(:participation).reload }

  before { sign_in(people(:bulei)) }

  context 'GET#new' do
    it 'informs about email sent to participant' do
      get :new,
          group_id: group.id,
          event_id: course.id,
          event_participation: { person_id: people(:child).id }
      expect(flash[:notice]).to be_present
    end
  end


  context 'GET#index' do
    it 'does not include tentative participants' do
      Fabricate(:event_participation,
                event: course,
                state: 'applied',
                person: people(:child),
                active: true)
      get :index, group_id: group.id, event_id: course.id
      expect(assigns(:participations)).to be_empty
    end
  end

  context 'POST#create' do

    # TODO ama this allows creating participations for people which are not visible to user
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

    it 'sets participation state to applied' do
      post :create,
           group_id: group.id,
           event_id: course.id,
           event_participation: { person_id: people(:bulei).id }
      expect(participation.state).to eq 'applied'
    end

    it 'sets participation state to assigned when created by organisator' do
      post :create,
           group_id: group.id,
           event_id: course.id,
           event_participation: { person_id: people(:child).id }
      expect(participation.state).to eq 'assigned'
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

    it 'requires canceled_at date' do
      expect do
        post :cancel,
             group_id: group.id,
             event_id: course.id,
             id: participation.id,
             event_participation: { canceled_at: ' ' }
      end.not_to change { Delayed::Job.count }
      expect(flash[:alert]).to be_present
      participation.reload
      expect(participation.canceled_at).to eq nil
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

end
