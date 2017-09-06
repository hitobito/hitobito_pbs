# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ApprovalsController do

  let(:group) { course.groups.first }
  let(:al_schekka) { people(:al_schekka) }
  let(:bulei) { people(:bulei) }
  let(:participant) { people(:child) }
  let(:course) do
    Fabricate(:course,
              groups: [groups(:schekka)],
              kind: event_kinds(:lpk),
              requires_approval_abteilung: true)
  end
  let(:participation) do
    Fabricate(:pbs_participation, event: course, person: participant, application: application)
  end
  let(:application) { Fabricate(:pbs_application, priority_1: course) }
  let(:course_start_date) { Fabricate(:event_date, event: course, start_at: 10.days.from_now) }

  before do
    participation.application.reload
    course.dates.destroy_all
    course_start_date
    course.reload
  end


  context 'GET index' do

    let(:course) do
      Fabricate(:course,
                groups: [groups(:bund)],
                kind: event_kinds(:lpk),
                requires_approval_abteilung: true,
                requires_approval_region: true,
                requires_approval_kantonalverband: true)
    end

    before do
      @p1 = Fabricate(:pbs_participation,
                      event: course,
                      active: true,
                      state: 'assigned',
                      application: Fabricate(:pbs_application, priority_1: course))
      @p2 = Fabricate(:pbs_participation,
                      event: course,
                      active: true,
                      state: 'assigned',
                      application: Fabricate(:pbs_application, priority_1: course))
      @p3 = Fabricate(:pbs_participation,
                      event: course,
                      active: true,
                      state: 'assigned',
                      application: Fabricate(:pbs_application, priority_1: course))
      @p4 = Fabricate(:pbs_participation,
                      event: course,
                      application: Fabricate(:pbs_application, priority_1: course))
      Fabricate(Event::Course::Role::Participant.name, participation: @p1)
      Fabricate(Event::Course::Role::Participant.name, participation: @p2)
      Fabricate(Event::Course::Role::Participant.name, participation: @p3)

      @a11 = create_approval(@p1, 'abteilung', true)
      @a12 = create_approval(@p1, 'region', true)
      @a13 = create_approval(@p1, 'kantonalverband', true)

      @a21 = create_approval(@p2, 'abteilung', true)
      @a22 = create_approval(@p2, 'region', false)

      @a31 = create_approval(@p3, 'abteilung', true)
      @a32 = @p3.application.approvals.create!(layer: 'region')

      @a41 = create_approval(@p4, 'abteilung', true)
      @a42 = create_approval(@p4, 'region', true)
      @a43 = @p4.application.approvals.create!(layer: 'kantonalverband')

      sign_in(people(:bulei))
    end

    it 'lists grouped approvals' do
      get :index, group_id: group.id, event_id: course.id

      list = [@p1, @p2, @p3].sort_by { |p| p.person.last_name }

      expect(assigns(:approvals).keys).to eq(list)

      expect(assigns(:approvals)[@p1]).to eq([@a11, @a12, @a13])
      expect(assigns(:approvals)[@p2]).to eq([@a21, @a22])
      expect(assigns(:approvals)[@p3]).to eq([@a31, @a32])
    end

    def create_approval(participation, layer, approved)
      participation.application.approvals.create!(
        layer: layer,
        approved: approved,
        rejected: !approved,
        approver: people(:al_schekka),
        current_occupation: 'Venner',
        current_level: 'Pfadi',
        occupation_assessment: 'super',
        strong_points: 'viele',
        weak_points: 'keine',
        comment: 'nein')
    end

  end

  context 'GET new' do

    context 'bulei' do
      before do
        sign_in(bulei)
        application.approvals.create!(layer: 'abteilung')
        participant.update!(primary_group: groups(:pegasus))
      end

      it 'may not approve' do
        expect { new_approve }.to raise_error CanCan::AccessDenied
      end

      it 'may not reject' do
        expect { new_reject }.to raise_error CanCan::AccessDenied
      end
    end

    context 'al schekka' do
      before do
        sign_in(al_schekka)
        application.approvals.create!(layer: 'abteilung')
        participant.update!(primary_group: groups(:pegasus))
      end

      describe 'approve' do
        before { new_approve  }

        it { is_expected.to render_template 'new' }
        it { expect(assigns(:approval)).to eq(application.reload.approvals.first) }
      end

      describe 'reject' do
        before { new_reject }

        it { is_expected.to render_template 'new' }
        it { expect(assigns(:approval)).to eq(application.reload.approvals.first) }
      end
    end

    def new_approve
      get :new, group_id: group.id, event_id: course.id, participation_id: participation.id, decision: :approve
    end

    def new_reject
      get :new, group_id: group.id, event_id: course.id, participation_id: participation.id, decision: :reject
    end

  end

  context 'POST create' do

    context 'bulei' do
      before do
        sign_in(bulei)
        application.approvals.create!(layer: 'abteilung')
        participant.update!(primary_group: groups(:pegasus))
      end

      it 'may not approve' do
        expect { approve }.to raise_error CanCan::AccessDenied
      end

      it 'may not reject' do
        expect { reject }.to raise_error CanCan::AccessDenied
      end
    end

    context 'al schekka' do
      before do
        sign_in(al_schekka)
        application.approvals.create!(layer: 'abteilung')
        participant.update!(primary_group: groups(:pegasus))
      end

      describe 'approve' do
        before { approve  }

        it { is_expected.to redirect_to(group_event_participation_path(group, course, participation)) }

        it 'sets flash' do
          expect(flash[:notice]).to match(/freigegeben/)
        end

        it 'approves application' do
          expect(application.reload).to be_approved
          expect(application.reload).not_to be_rejected
        end

        it 'approves approval' do
          expect(application.reload.approvals.first).to be_approved
          expect(application.reload.approvals.first.comment).to eq 'test'
        end

      end

      context 'approve with invalid fields' do
        it 'renders form again if fields are blank' do
          post :create,
               group_id: group.id,
               event_id: course.id,
               participation_id: participation.id,
               decision: 'approve',
               event_approval: {
                 comment: nil,
                 current_occupation: 'chief',
                 current_level: '',
                 occupation_assessment: '  '
               }

          is_expected.to render_template('new')
          expect(application.reload.approvals.first).not_to be_approved
          expect(assigns(:approval).errors.size).to eq(4)
        end
      end

      describe 'reject' do
        before { reject }

        it { is_expected.to redirect_to(group_event_participation_path(group, course, participation)) }

        it 'sets flash' do
          expect(flash[:notice].first).to match(/abgelehnt/)
          expect(flash[:notice].second).to match(/Bitte informiere .* persönlich/)
        end

        it 'rejects application' do
          expect(application.reload).to be_rejected
          expect(application.reload).not_to be_approved
        end

        it 'rejects approval' do
          expect(application.reload.approvals.first).to be_rejected
          expect(application.reload.approvals.first.comment).to eq 'test'
        end
      end
    end

    def approve
      post :create,
           group_id: group.id,
           event_id: course.id,
           participation_id: participation.id,
           decision: 'approve',
           event_approval: {
             comment: 'test',
             current_occupation: 'chief',
             current_level: 'junior',
             occupation_assessment: 'good',
             strong_points: 'strong',
             weak_points: 'weak'
           }
    end

    def reject
      post :create,
           group_id: group.id,
           event_id: course.id,
           participation_id: participation.id,
           decision: 'reject',
           event_approval: {
             comment: 'test',
             current_occupation: 'chief',
             current_level: 'junior',
             occupation_assessment: 'good',
             strong_points: 'strong',
             weak_points: 'weak'
           }
    end

  end

  context 'GET edit' do

    let(:approver) { al_schekka }
    let(:approval) { @approval }

    context 'bulei' do
      before do
        sign_in(bulei)
        @approval = application.approvals.create!(layer: 'abteilung')
        participant.update!(primary_group: groups(:pegasus))
        approve_application!
      end

      it 'may not edit' do
        expect { edit_approval }.to raise_error CanCan::AccessDenied
      end
    end

    context 'al schekka' do
      before do
        sign_in(al_schekka)
        @approval = application.approvals.create!(layer: 'abteilung')
        participant.update!(primary_group: groups(:pegasus))
        approve_application!
      end

      describe 'edit' do
        before { edit_approval  }

        it { is_expected.to render_template 'edit' }
        it { expect(assigns(:approval)).to eq(application.reload.approvals.first) }
      end

    end

    def edit_approval
      get :edit, group_id: group.id, event_id: course.id, participation_id: participation.id, id: approval.id
    end

    def approve_application!
      approval.update(
        approved:               true,
        approver:               approver,
        current_occupation:     'Verantwortlicher PR',
        current_level:          'Meister',
        occupation_assessment:  'Zuverlässig',
        strong_points:          'kann gut verkaufen',
        weak_points:            'muss noch Zurückhaltung üben'
      )
      approval.reload
    end

  end

end
