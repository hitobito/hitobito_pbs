# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

require 'event/roles_controller'

describe Event::RolesController do

  let(:group) { event.groups.first }

  before { sign_in(people(:bulei)) }

  context 'POST create' do

    context 'simple' do
      let(:event) { events(:top_event) }

      it 'creates helper in state nil' do
        expect do
          post :create,
               group_id: group.id,
               event_id: event.id,
               event_role: {
                 type: Event::Role::Cook.sti_name,
                 person_id: people(:al_berchtold).id
               }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to be_nil
      end
    end

    context 'course' do
      let(:event) { events(:top_course) }

      it 'creates helper in state assigned' do
        expect do
          post :create,
               group_id: group.id,
               event_id: event.id,
               event_role: {
                 type: Event::Role::Cook.sti_name,
                 person_id: people(:al_berchtold).id
               }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq 'assigned'
      end
    end

    context 'camp' do
      let(:event) { events(:schekka_camp) }

      it 'creates helper in state assigned' do
        expect do
          post :create,
               group_id: group.id,
               event_id: event.id,
               event_role: {
                 type: Event::Camp::Role::Helper.sti_name,
                 person_id: people(:al_berchtold).id
               }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq 'assigned'
      end

      it 'creates participant in state assigned' do
        expect do
          post :create,
               group_id: group.id,
               event_id: event.id,
               event_role: {
                 type: Event::Camp::Role::Participant.sti_name,
                 person_id: people(:al_berchtold).id
               }
        end.to change { Event::Participation.count }.by(1)

        role = assigns(:role)
        expect(role).to be_persisted
        expect(role.participation.state).to eq 'assigned'
      end

    end
  end

end
