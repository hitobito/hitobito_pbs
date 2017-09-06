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


  context 'al schekka' do
    before do
      sign_in(al_schekka)
      application.approvals.create!(layer: 'abteilung')
      participant.update!(primary_group: groups(:pegasus))
    end

    describe 'PUT approve' do
      it 'does not approves application' do
        expect { approve }.to raise_error(CanCan::AccessDenied)
      end

    end

    describe 'DELETE reject' do
      it 'does not rejects application' do
        expect { reject }.to raise_error(CanCan::AccessDenied)
      end

    end
  end

  def approve
    put :approve, group_id: group.id, event_id: course.id, id: application.id
  end

  def reject
    delete :reject, group_id: group.id, event_id: course.id, id: application.id
  end

end
