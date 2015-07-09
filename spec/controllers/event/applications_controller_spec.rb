# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ApplicationsController do

  let(:group) { course.groups.first }
  let(:al_schekka) { people(:al_schekka) }
  let(:participant) { people(:child) }
  let(:course) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk), requires_approval_abteilung: true) }
  let(:participation) {  Fabricate(:event_participation, event: course, person: participant) }
  let(:application) { participation.create_application(priority_1: course) }

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

    describe 'PUT approve' do
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

    describe 'DELETE reject' do
      before { reject }

      it { is_expected.to redirect_to(group_event_participation_path(group, course, participation)) }

      it 'sets flash' do
        expect(flash[:notice]).to match(/abgelehnt/)
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
    put :approve, group_id: group.id, event_id: course.id, id: application.id, event_approval: { comment: 'test' }
  end

  def reject
    delete :reject, group_id: group.id, event_id: course.id, id: application.id, event_approval: { comment: 'test' }
  end
end
