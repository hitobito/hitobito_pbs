# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventsController do

  context 'event_course' do
    let(:group) { groups(:bund) }
    let(:date)  { { label: 'foo', start_at_date: Date.today, finish_at_date: Date.today } }
    let(:event) { assigns(:event) }

    let(:event_attrs) { { group_ids: [group.id], name: 'foo',
                          kind_id: Event::Kind.where(short_name: 'LPK').first.id,
                          number: 234,
                          dates_attributes: [date], type: 'Event::Course' } }


    before { sign_in(people(:bulei)) }

    it 'creates new event course with dates, advisor' do
      post :create, event: event_attrs.merge(contact_id: Person.first, advisor_id: Person.last), group_id: group.id
      expect(event.dates).to have(1).item
      expect(event.dates.first).to be_persisted
      expect(event.contact).to eq Person.first
      expect(event.advisor).to eq Person.last
    end

    it 'creates new event course without contact, advisor' do
      post :create, event: event_attrs.merge(contact_id: '', advisor_id: ''), group_id: group.id

      expect(event.contact).not_to be_present
      expect(event.advisor).not_to be_present
      expect(event).to be_persisted
    end

  end

  context 'coach_confirmed' do
    let(:event) { events(:schekka_camp) }

    before { sign_in(people(:al_schekka)) }

    it 'allows coaches to edit coach_confirmed' do
      event.update!(coach_id: people(:al_schekka).id)

      put :update, group_id: event.groups.first.id,
                   id: event.id,
                   event: { coach_confirmed: true }
      expect(assigns(:event)).to be_valid
      expect(assigns(:event).coach_confirmed).to be_truthy
    end

    it 'prevents non-coaches from editing coach_confirmed' do
      put :update, group_id: event.groups.first.id,
                   id: event.id,
                   event: { coach_confirmed: true }
      expect(assigns(:event)).to be_valid
      expect(assigns(:event).coach_confirmed).to be_falsey
    end
  end

  context 'GET show_camp_application' do
    let(:event) { events(:schekka_camp) }

    context 'when authorized' do
      before { sign_in(people(:bulei)) }

      it 'renders pdf' do
        get :show_camp_application, group_id: event.groups.first.id, id: event.id
        expect(response).to be_ok
      end
    end

    context 'when unauthorized' do

      before { sign_in(people(:al_berchtold)) }

      it 'raises 401' do
        expect do
          get :show_camp_application, group_id: event.groups.first.id, id: event.id
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context 'PUT create_camp_application' do
    let(:event) { events(:schekka_camp) }

    context 'when authorized' do
      before { sign_in(people(:al_berchtold)) }
      before { event.update!(coach_id: people(:al_berchtold).id) }

      it 'fails if no canton given' do
        group = event.groups.first
        put :create_camp_application, group_id: group.id, id: event.id
        expect(response).to redirect_to(group_event_path(group, event))
        expect(flash[:alert]).to match /Kanton.* muss ausgefüllt werden/
        expect(event.reload).not_to be_camp_submitted
      end

      it 'sends mail if all is present' do
        group = event.groups.first
        event.update!(canton: 'be')

        mail = double('mail', deliver_later: nil)
        expect(Event::CampMailer).to receive(:submit_camp).and_return(mail)

        put :create_camp_application, group_id: group.id, id: event.id
        expect(response).to redirect_to(group_event_path(group, event))
        expect(flash[:notice]).to match /eingereicht/
        expect(event.reload).to be_camp_submitted
      end
    end

    context 'when unauthorized' do

      before { sign_in(people(:bulei)) }

      it 'raises 401' do
        expect do
          put :create_camp_application, group_id: event.groups.first.id, id: event.id
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'camp leader checkpoint attrs' do

      let(:camp) { events(:schekka_camp) }
      before { sign_in(people(:bulei)) }

      it 'is not possible for non camp leader user to update checkpoint attrs' do
        put :update, group_id: camp.groups.first.id, id: camp.id,
                     event: checkpoint_values

        Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
          expect(camp.send(attr)).to be false
        end
      end

      it 'is possible for camp leader to update checkpoint attrs' do
        camp.leader_id = people(:bulei).id
        camp.save!

        put :update, group_id: camp.groups.first.id, id: camp.id,
                     event: checkpoint_values

        camp.reload
        Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
          expect(camp.send(attr)).to be true
        end
      end

      def checkpoint_values
        values = {}
        Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
          values[attr.to_s] = '1'
        end
        values
      end
    end
  end
end
