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
        event.update!(camp_days: 3, canton: 'be')

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
  end

end
