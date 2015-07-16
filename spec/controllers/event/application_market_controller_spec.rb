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
