# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::TentativesController do

  let(:group) { groups(:be) }
  let(:course) { Fabricate(:pbs_course, groups: [group], tentative_applications: true) }

  before { sign_in(people(:bulei)) }

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
