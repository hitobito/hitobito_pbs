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
  let(:course) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk), requires_approval_abteilung: true) }
  let(:participation) {  Fabricate(:pbs_participation, event: course, person: participant) }
  let(:application) { participation.create_application(priority_1: course) }
  let(:dom) { Capybara::Node::Simple.new(response.body) }

  context 'approve and reject buttons' do
    before do
      application.approvals.create!(layer: 'abteilung')
      participant.update!(primary_group: groups(:pegasus))
    end

    it 'bulei does not see approve and reject buttons' do
      sign_in(people(:bulei))

      get :show, group_id: group.id, event_id: course.id, id: participation.id
      expect(dom).not_to have_content 'Freigeben'
      expect(dom).not_to have_content 'Ablehnen'
    end

    it 'al_schekka sees approve and reject buttons' do
      sign_in(al_schekka)

      get :show, group_id: group.id, event_id: course.id, id: participation.id
      expect(dom).to have_content 'Freigeben'
      expect(dom).to have_content 'Ablehnen'
    end
  end

  context 'pending approvals' do
    before { participation.update(application: application) }

    context 'al schekka' do
      before { sign_in(al_schekka) }

      it 'sees Empfehlungen aside' do
        application.approvals.create!(layer: 'abteilung', comment: 'all good', approved: true, approver: al_schekka)
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

  context 'reject participation' do
    before { participation.update(application: application) }

    context 'show reject button' do
      before { sign_in(al_schekka) }

      it 'does not see Anmeldung ablehnen when participation canceled' do
        participation.update_attribute(:state, 'canceled')
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom).not_to have_content 'Ablehnen'
      end

      it 'does not see Anmeldung ablehnen when participation rejected' do
        participation.update_attribute(:state, 'rejected')
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom).not_to have_content 'Ablehnen'
      end

      it 'sees Anmeldung ablehnen when participation applied' do
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom).to have_content 'Ablehnen'
      end

      it 'sees Anmeldung ablehnen when participation assigned' do
        participation.update_attribute(:state, 'assigned')
        get :show, group_id: group.id, event_id: course.id, id: participation.id
        expect(dom).to have_content 'Ablehnen'
      end
    end

    context 'reject participation' do
      before { sign_in(al_schekka) }

      it 'rejects participation and show mailto link in flash' do
        get :reject, group_id: group.id, event_id: course.id, id: participation.id
        is_expected.to redirect_to group_event_participation_path(group, course, participation)
        expect(flash[:notice]).to match(/wurde abgelehnt/)
        # TODO check for mail_to links with email addresses
      end

    end

  end
end
