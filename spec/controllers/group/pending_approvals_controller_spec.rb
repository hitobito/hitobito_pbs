# encoding: utf-8

#  Copyright (c) 2015-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Group::PendingApprovalsController do

  let(:course) { events(:top_course) }
  let(:person) { people(:child) }
  let(:participation) { Fabricate(:pbs_participation, event: course, person: person) }
  let(:other_participation) { event_participations(:top_participant) }

  def create_application_and_approval(participation)
    application = participation.create_application(priority_1: course)
    application.approvals.create!(layer: 'kantonalverband')
  end

  before do
    person.update(primary_group: groups(:pegasus))
    people(:al_schekka).update(primary_group: groups(:be))
    other_participation.update(created_at: 1.year.ago)
    create_application_and_approval(participation)
    @other_approval = create_application_and_approval(other_participation)
  end

  it 'lists pending approvals for layers oldest at the top' do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    sign_in(people(:bulei))
    get :index, id: groups(:be).id
    expect(assigns(:approvals)).to have(2).item
    expect(assigns(:approvals).first).to eq @other_approval
  end

  it 'denies access to listing if not authorized' do
    sign_in(people(:bulei))
    expect { get :index, id: groups(:be).id }.to raise_error CanCan::AccessDenied
  end

  it 'updates application_approver_role to role with :approve_applications' do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    sign_in(people(:bulei))
    patch :update_role, id: groups(:be).id, approver_role: Group::Kantonalverband::VerantwortungAusbildung.name
    expect(groups(:be).reload.application_approver_role).to eq(Group::Kantonalverband::VerantwortungAusbildung.name)
  end

  it 'updates application_approver_role to all roles if blank' do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    sign_in(people(:bulei))
    patch :update_role, id: groups(:be).id, approver_role: '  '
    expect(groups(:be).reload.application_approver_role).to eq(nil)
  end

end
