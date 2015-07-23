# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::TentativesController do

  let(:group) { groups(:be) }
  let(:course) { Fabricate(:pbs_course, groups: [group], tentative_applications: true) }

  before { sign_in(people(:bulei)) }

  context 'GET#index' do
    def create_participation(role, group, state)
      person = Fabricate(role.name, group: group).person
      Fabricate(:pbs_participation, event: course, person: person, state: state)
    end

    def fetch_count(name)
      assigns(:counts).fetch([groups(name).id, groups(name).name])
    end

    it 'counts tentative applications grouped by layer_group' do
      create_participation(Group::Kantonalverband::Mitarbeiter, groups(:be), 'tentative')
      create_participation(Group::KantonalesGremium::Mitglied, groups(:fg_security), 'tentative')
      create_participation(Group::KantonalesGremium::Mitglied, groups(:fg_football), 'tentative')
      create_participation(Group::KantonalesGremium::Mitglied, groups(:fg_football), 'assigned')

      create_participation(Group::Abteilung::Praeses, groups(:schekka), 'tentative')

      get :index, group_id: course.groups.first.id, event_id: course.id

      expect(assigns(:counts)).to have(2).items
      expect(fetch_count(:be)).to eq 3
      expect(fetch_count(:schekka)).to eq 1
    end


    it 'raises AccessDenied if not permitted to list_tentatives on event' do
      sign_in(people(:al_schekka))
      course = Fabricate(:pbs_course, groups: [groups(:bund)], tentative_applications: true)
      expect do
        get :index, group_id: course.groups.first.id, event_id: course.id
      end.to raise_error CanCan::AccessDenied
    end
  end

  context 'POST#create' do
    let(:participation) { assigns(:participation) }

    it 'raises CanCan::AccessDenied when course does not support tentative applications' do
      course.update(tentative_applications: false)
      expect do
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: people(:al_schekka).id }
      end.to raise_error CanCan::AccessDenied
    end

    it 'raises CanCan::AccessDenied when person is not accessible' do
      expect do
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: people(:child).id }
      end.to raise_error CanCan::AccessDenied
    end

    it 'sets participation state to tentative' do
      post :create,
           group_id: group.id,
           event_id: course.id,
           event_participation: { person_id: people(:al_schekka).id }

      expect(participation.state).to eq 'tentative'
      expect(participation.active).to eq(false)
      expect(participation.application).to be_nil
      expect(participation.roles).to have(1).item
      expect(participation.roles.first.class).to eq Event::Course::Role::Participant
    end

    it 'does not send email' do
      expect do
        course.update(tentative_applications: true, state: 'created')
        post :create,
             group_id: group.id,
             event_id: course.id,
             event_participation: { person_id: people(:al_schekka).id }
      end.not_to change { Delayed::Job.count }
    end
  end

  context 'GET#query' do
    let(:json) { JSON.parse(response.body) }

    it "returns people as typeahead" do
      sign_in(people(:al_schekka))

      get :query, group_id: group.id, event_id: course.id, q: 'Child', format: :js
      expect(json).to have(1).item
      expect(json.first['label']).to eq 'My Child'
    end

    it "only finds people for which user may update" do
      sign_in(people(:bulei))

      get :query, group_id: group.id, event_id: course.id, q: 'Child', format: :js
      expect(json).to be_empty
    end
  end

end
