# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ApprovalsController do

  let(:group) { course.groups.first }
  let(:al_schekka) { people(:al_schekka) }
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

  before { participation.application.reload }

  context 'GET new' do

    context 'bulei' do
      before do
        sign_in(people(:bulei))
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
        sign_in(people(:bulei))
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

end
