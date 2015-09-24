# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ApplicationAbility do

  let(:course)   { events(:top_course) }
  let(:application) { @application }

  def create_application(role, group, approving_layer)
    person = Fabricate(role.name, group: group).person
    application = Fabricate(:event_application, priority_1: course, priority_2: nil)
    Fabricate(:pbs_participation, event: course, application: application, person: person)
    application.approvals.create!(layer: approving_layer)
    @application = application.reload
  end

  def create_approver(role, group)
    @approver = Fabricate(role.name, group: group)
  end

  subject { Ability.new(@approver.person) }

  context 'approving and rejecting applications' do

    it "may approve and reject in same layer" do
      create_approver(Group::Bund::Geschaeftsleitung, groups(:bund))
      create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')

      is_expected.to be_able_to(:approve, application)
      is_expected.to be_able_to(:reject, application)
    end

    it 'may approve and reject in same layer in hierarchy' do
      create_approver(Group::Bund::Geschaeftsleitung, groups(:bund))
      create_application(Group::Kantonalverband::Mitarbeiter, groups(:be), 'bund')

      is_expected.to be_able_to(:approve, application)
      is_expected.to be_able_to(:reject, application)
    end

    it 'may approve and reject in same layer in hierarchy if above' do
      nested = Fabricate(Group::Region.name, parent: groups(:bern))
      create_approver(Group::Region::Regionalleitung, groups(:bern))
      create_application(Group::Region::Mitarbeiter, nested, 'region')

      is_expected.to be_able_to(:approve, application)
      is_expected.to be_able_to(:reject, application)
    end

    it 'may not approve and reject in same layer in hierarchy if below' do
      nested = Fabricate(Group::Region.name, parent: groups(:bern))
      create_approver(Group::Region::Regionalleitung, nested)
      create_application(Group::Region::Mitarbeiter, groups(:bern), 'region')

      is_expected.not_to be_able_to(:approve, application)
      is_expected.not_to be_able_to(:reject, application)
    end

    it 'may not approve or reject in same layer outside of hierarchy' do
      create_approver(Group::Kantonalverband::Kantonsleitung, groups(:zh))
      create_application(Group::Kantonalverband::Mitarbeiter, groups(:be), 'kantonalverband')

      is_expected.not_to be_able_to(:approve, application)
      is_expected.not_to be_able_to(:reject, application)
    end

    it 'may not approve or reject in different layer in hierarchy' do
      create_approver(Group::Bund::Geschaeftsleitung, groups(:bund))
      create_application(Group::Kantonalverband::Mitarbeiter, groups(:be), 'kantonalverband')

      is_expected.not_to be_able_to(:approve, application)
      is_expected.not_to be_able_to(:reject, application)
    end

  end


  context 'showing approvals' do

    context 'approve_applications permission' do
      [ %w(bund Geschaeftsleitung),
        %w(be Kantonsleitung),
        %w(bern Regionalleitung),
        %w(patria Abteilungsleitung)].each do |name, role|
          it "#{role} in #{name} may show approvals for participant of patria" do
            group = groups(name)
            create_approver("#{group.type}::#{role}".constantize, group)
            create_application(Group::Abteilung::Praeses, groups(:patria), 'bund')
            is_expected.to be_able_to(:show_approval, application)
          end
        end

      it 'Kantonsleitung in zh may not show approvals for participant of patria' do
        create_approver(Group::Kantonalverband::Kantonsleitung, groups(:zh))
        create_application(Group::Abteilung::Praeses, groups(:patria), 'bund')
        is_expected.not_to be_able_to(:show_approval, application)
      end
    end

    context 'leader and participants' do
      it 'course leader may show_approval' do
        @approver = event_roles(:top_leader)
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        is_expected.to be_able_to(:show_approval, application)
      end

      it 'course participant may not show_approval' do
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        @approver = application.participation
        is_expected.not_to be_able_to(:show_approval, application)
      end

      it 'other course participant may not show_approval' do
        @approver = event_roles(:top_tn)
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        is_expected.not_to be_able_to(:show_approval, application)
      end
    end

    context 'group and layers' do
      it ':layer_full of may show approvals of same layer group' do
        create_approver(Group::Kantonalverband::VerantwortungAusbildung, groups(:be))
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        is_expected.to be_able_to(:show_approval, application)
      end

      it ':layer_full of may show approvals of same layer' do
        course.groups << groups(:zh)
        create_approver(Group::Kantonalverband::VerantwortungAusbildung, groups(:zh))
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        is_expected.to be_able_to(:show_approval, application)
      end

      it ':layer_full of may not show approvals of layer below' do
        create_approver(Group::Bund::AssistenzAusbildung, groups(:bund))
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        is_expected.not_to be_able_to(:show_approval, application)
      end

      it ':layer_full_and_below may show approvals of layer below' do
        create_approver(Group::Bund::MitarbeiterGs, groups(:bund))
        create_application(Group::Bund::Mitarbeiter, groups(:bund), 'bund')
        is_expected.to be_able_to(:show_approval, application)
      end

      it ':layer_full_and_below may show approvals of different layer when application is on waiting list' do
        course.groups = [groups(:zuerich)]
        course.save!

        create_approver(Group::Region::Regionalleitung, groups(:bern))
        create_application(Group::Region::Mitarbeiter, groups(:zuerich), 'bund')

        application.update(waiting_list: true)
        is_expected.to be_able_to(:show_approval, application)
      end
    end
  end

end
