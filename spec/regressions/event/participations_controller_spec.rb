# encoding: utf-8
#
#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationsController, type: :controller  do

  render_views

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
    Fabricate(:pbs_participation,
              event: course,
              person: participant,
              application: Fabricate(:pbs_application, priority_1: course))
  end

  let(:dom) { Capybara::Node::Simple.new(response.body) }

  context 'approve and reject buttons' do
    before { participation.application.approvals.create!(layer: 'abteilung') }
    it 'bulei does not see approve and reject buttons' do
      sign_in(people(:bulei))

      get :show, group_id: group.id, event_id: course.id, id: participation.id
      expect(dom).not_to have_content 'Freigeben'
      expect(dom).not_to have_content 'Ablehnen'
    end

    it 'al schekka sees approve and reject buttons' do
      sign_in(al_schekka)

      get :show, group_id: group.id, event_id: course.id, id: participation.id
      expect(dom).to have_content 'Freigeben'
      expect(dom).to have_content 'Ablehnen'
    end
  end

  context 'pending approvals' do
    context 'al schekka' do
      before { sign_in(al_schekka) }

      it 'sees Empfehlungen aside' do
        participation.application.approvals.create!(layer: 'abteilung',
                                                    comment: 'all good',
                                                    approved: true,
                                                    approver: al_schekka)

        get :show, group_id: group.id, event_id: course.id, id: participation.id

        expect(dom).to have_content 'Empfehlungen'
        expect(dom).to have_css('.badge.badge-success')
        expect(dom).to have_content '✓'
        expect(dom).to have_content 'all good'
      end
    end

    context 'participant' do
      before { sign_in(people(:child)) }

      it 'does not see Empfehlungen aside' do
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom).not_to have_content 'Empfehlungen'
      end
    end
  end

end
