# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ApplicationMarketController do

  let(:group) { course.groups.first }
  let(:course) { events(:top_course) }
  let(:participation) {  event_participations(:top_participant) }

  before do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    participation.create_application!(priority_1: course)
    sign_in(people(:bulei))
  end

  it 'PUT#add_participant sets application state to assigned' do
    put :add_participant, group_id: group.id, event_id: course.id, id: participation.id, format: :js
    expect(participation.reload.state).to eq 'assigned'
  end


  it 'DELETE#remove_participant sets application state to applied' do
    delete :remove_participant, group_id: group.id, event_id: course.id, id: participation.id, format: :js
    expect(participation.reload.state).to eq 'applied'
  end


  context 'notifiying waiting_list_setter' do

    before do
      participation.update!(waiting_list_setter: people(:al_schekka))
      participation.application.update!(waiting_list: true)
    end

    it 'PUT#add_participant enqueues notification job' do
      expect(Event::AssignedFromWaitingListJob).to receive(:new).with(participation, people(:bulei)).and_call_original
      expect do
        put :add_participant, group_id: group.id, event_id: course.id, id: participation.id, format: :js
      end.to change { Delayed::Job.count }.by(1)
    end

    it 'PUT#add_participant does not enqueue job if waiting_list_setter equals current user' do
      participation.update!(waiting_list_setter: people(:bulei))

      expect do
        put :add_participant, group_id: group.id, event_id: course.id, id: participation.id, format: :js
      end.not_to change { Delayed::Job.count }
    end

    it 'PUT#add_participant does not enqueue job if assigner cannot create' do
      participation.update(event: Fabricate(:pbs_course))

      expect do
        put :add_participant, group_id: group.id, event_id: course.id, id: participation.id, format: :js
      end.not_to change { Delayed::Job.count }
    end

    it 'DELETE#remove_from_waiting_list enqueues notification job' do
      expect(Event::RemovedFromWaitingListJob).to receive(:new).with(participation, people(:bulei)).and_call_original
      expect do
        delete :remove_from_waiting_list, group_id: group.id, event_id: course.id, id: participation.id, format: :js
      end.to change { Delayed::Job.count }.by(1)
    end

    it 'DELETE#remove_from_waiting_list does not enqueue job when waiting_list_setter equals current_user' do
      participation.update!(waiting_list_setter: people(:bulei))
      expect do
        delete :remove_from_waiting_list, group_id: group.id, event_id: course.id, id: participation.id, format: :js
      end.not_to change { Delayed::Job.count }
    end

    it 'DELETE#remove_participant sets waiting_list_setter to current_user' do
      delete :remove_participant, group_id: group.id, event_id: course.id, id: participation.id, format: :js
      expect(participation.reload.waiting_list_setter).to eq people(:bulei)
    end

    it 'PUT#put_on_waiting_list sets waiting_list_setter to current_user' do
      put :put_on_waiting_list, group_id: group.id, event_id: course.id, id: participation.id, event_application: {}, format: :js
      expect(participation.reload.waiting_list_setter).to eq people(:bulei)
    end

  end

  def create_participant(state = 'applied')
    participation = Fabricate(:pbs_participation, event: course, state: state)
    participation.roles.create!(type: Event::Course::Role::Participant.name)
  end

  it 'GET#index does not list tentative applications' do
    other = create_participant.participation
    tentative = create_participant('tentative')

    get :index, group_id: group.id, event_id: course.id
    expect(assigns(:participants)).to include(other)
    expect(assigns(:participants)).not_to include(tentative)
  end

end
