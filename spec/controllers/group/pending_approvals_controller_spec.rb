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

  it 'lists pending approvals for layer oldest at the top' do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei),
                                                           group: groups(:be))
    sign_in(people(:bulei))
    get :index, id: groups(:be).id
    expect(assigns(:pending_approvals)).to have(2).item
    expect(assigns(:pending_approvals).first).to eq @other_approval
  end

  it 'denies access to listing if not authorized' do
    sign_in(people(:bulei))
    expect { get :index, id: groups(:be).id }.to raise_error CanCan::AccessDenied
  end

  it 'updates application_approver_role to role with :approve_applications' do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    sign_in(people(:bulei))
    patch :update_role, id: groups(:be).id,
                        approver_role: Group::Kantonalverband::VerantwortungAusbildung.name
    expect(groups(:be).reload.application_approver_role)
      .to eq(Group::Kantonalverband::VerantwortungAusbildung.name)
  end

  it 'updates application_approver_role to all roles if blank' do
    Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
    sign_in(people(:bulei))
    patch :update_role, id: groups(:be).id, approver_role: '  '
    expect(groups(:be).reload.application_approver_role).to eq(nil)
  end

  context 'approved approvals' do
    before do
      @approved_approval = create_application_and_approval(participation)
      @approved_approval.update!(approved: true, approved_at: Time.zone.now,
                                 approver: people(:bulei))
      course2 = Fabricate(:course, groups: course.groups, kind: event_kinds(:bkws))
      other_participation.update!(event_id: course2.id)
      @other_approved_approval = create_application_and_approval(other_participation)
      @other_approved_approval.update!(approved: true, approved_at: Time.zone.now,
                                       approver: people(:bulei))

      p = Fabricate(:event_participation, person: people(:al_schekka))
      @rejected_approval = create_application_and_approval(p)
      @rejected_approval.update!(rejected: true)
    end

    it 'lists approved approvals for layer newest at the top' do
      Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
      sign_in(people(:bulei))
      get :index, id: groups(:be).id
      expect(assigns(:approved_approvals)).to have(2).item
      expect(assigns(:approved_approvals).first).to eq @other_approved_approval
      expect(assigns(:approved_course_kinds)).to eq([event_kinds(:lpk), event_kinds(:bkws)])
    end

    it 'provides action get approved approvals filterable by course kind via xhr' do
      Fabricate(Group::Kantonalverband::Kantonsleitung.name, person: people(:bulei), group: groups(:be))
      sign_in(people(:bulei))
      xhr :get, :approved, id: groups(:be).id, course_kind_id: event_kinds(:lpk).id
      expect(assigns(:approved_approvals)).to have(1).item
      expect(assigns(:approved_approvals).first).to eq @approved_approval
      expect(assigns(:approved_course_kinds)).to eq([event_kinds(:lpk), event_kinds(:bkws)])
    end
  end

end
