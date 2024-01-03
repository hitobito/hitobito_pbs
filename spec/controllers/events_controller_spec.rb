#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
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
      post :create, params: { event: event_attrs.merge(contact_id: Person.first, advisor_id: Person.last), group_id: group.id }
      expect(event.dates).to have(1).item
      expect(event.dates.first).to be_persisted
      expect(event.contact).to eq Person.first
      expect(event.advisor).to eq Person.last
    end

    it 'creates new event course without contact, advisor' do
      post :create, params: { event: event_attrs.merge(contact_id: '', advisor_id: ''), group_id: group.id }

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

      put :update, params: {
                     group_id: event.groups.first.id,
                     id: event.id,
                     event: { coach_confirmed: true }
                   }
      expect(assigns(:event)).to be_valid
      expect(assigns(:event).coach_confirmed).to be_truthy
    end

    it 'prevents non-coaches from editing coach_confirmed' do
      put :update, params: {
                     group_id: event.groups.first.id,
                     id: event.id,
                     event: { coach_confirmed: true }
                   }
      expect(assigns(:event)).to be_valid
      expect(assigns(:event).coach_confirmed).to be_falsey
    end

    context 'campy course' do
      let(:event) { Fabricate(:course, kind: event_kinds(:fut)) }

      it 'allows coaches to edit coach_confirmed for campy courses' do
        event.update!(coach_id: people(:al_schekka).id)

        put :update, params: {
              group_id: event.groups.first.id,
              id: event.id,
              event: { coach_confirmed: true }
            }
        expect(assigns(:event)).to be_valid
        expect(assigns(:event).coach_confirmed).to be_truthy
      end

      it 'prevents non-coaches from editing coach_confirmed' do
        event.participations.create!(person: people(:al_schekka),
                                    roles: [Event::Course::Role::Leader.new],
                                    j_s_data_sharing_accepted_at: Time.zone.now)
        put :update, params: {
          group_id: event.groups.first.id,
          id: event.id,
          event: { coach_confirmed: true }
        }
        expect(assigns(:event)).to be_valid
        expect(assigns(:event).coach_confirmed).to be_falsey
      end

      it 'prevents participations from updating' do
        expect do
          put :update, params: {
            group_id: event.groups.first.id,
            id: event.id,
            event: { coach_confirmed: true }
          }
        end.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  context 'camp application preview' do

    let(:person) { people(:bulei) }
    before { sign_in(person) }

    def fill_in_required_columns(event)
      event.update!(
        canton: Cantons.short_name_strings.first,
        location: 'Somewheretown',
        altitude: '1000',
        emergency_phone: '117',
        landlord: 'Netter Bauer von nebenan',
        coach_id: event.coach_id || people(:al_schekka).id,
        leader_id: event.leader_id || people(:al_schekka).id,
        lagerreglement_applied: true,
        kantonalverband_rules_applied: true,
        j_s_rules_applied: true,
        coordinates: '2604\'870, 1211\'271',
        expected_participants_wolf_f: 1,
      )
      event.update_columns(coach_confirmed: true)
    end

    context 'camp' do
      let(:event) { events(:schekka_camp) }

      context 'as camp leader' do
        before { event.update!(coach_id: people(:al_berchtold).id, leader_id: person.id, abteilungsleitung_id: people(:al_berchtold).id) }

        it 'shows failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to match /Das Lager kann noch nicht durch den\*die Coach eingereicht werden:/
          expect(flash[:notice]).to be_blank
        end

        it 'shows success message on successful validation' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to eq 'Es sind alle Informationen zum Einreichen des Lagers vorhanden.'
        end

        it 'shows no message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end

      end

      context 'as coach' do
        before { event.update!(coach_id: person.id, leader_id: people(:al_berchtold).id, abteilungsleitung_id: people(:al_berchtold).id) }

        it 'shows failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to match /Das Lager kann noch nicht durch den\*die Coach eingereicht werden:/
          expect(flash[:notice]).to be_blank
        end

        it 'shows success message on successful validation' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to eq 'Es sind alle Informationen zum Einreichen des Lagers vorhanden.'
        end

        it 'shows no message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end
      end

      context 'as abteilungsleitung' do
        before { event.update!(coach_id: people(:al_berchtold).id, leader_id: people(:al_berchtold).id, abteilungsleitung_id: person.id) }

        it 'shows failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to match /Das Lager kann noch nicht durch den\*die Coach eingereicht werden:/
          expect(flash[:notice]).to be_blank
        end

        it 'shows success message on successful validation' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to eq 'Es sind alle Informationen zum Einreichen des Lagers vorhanden.'
        end

        it 'shows no message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end
      end

      context 'as co-leader' do
        before do
          Fabricate(Event::Camp::Role::AssistantLeader.name.to_sym, person: person, event: event)
          event.update!(coach_id: people(:al_berchtold).id, leader_id: people(:al_schekka).id)
        end

        it 'does not show failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end

        it 'does not show success message' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end

        it 'does not show message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end
      end

    end

    context 'campy course' do
      let(:event) { Fabricate(:course, kind: event_kinds(:fut)) }

      context 'as course leader' do
        before { event.update!(coach_id: people(:al_berchtold).id, leader_id: person.id) }

        it 'shows failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to match /Das Lager kann noch nicht durch den\*die Coach eingereicht werden:/
          expect(flash[:notice]).to be_blank
        end

        it 'shows success message on successful validation' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to eq 'Es sind alle Informationen zum Einreichen des Lagers vorhanden.'
        end

        it 'shows no message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end

      end

      context 'as coach' do
        before { event.update!(coach_id: person.id, leader_id: people(:al_berchtold).id) }

        it 'shows failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to match /Das Lager kann noch nicht durch den\*die Coach eingereicht werden:/
          expect(flash[:notice]).to be_blank
        end

        it 'shows success message on successful validation' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to eq 'Es sind alle Informationen zum Einreichen des Lagers vorhanden.'
        end

        it 'shows no message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end
      end

      context 'as co-leader' do
        before do
          Fabricate(Event::Course::Role::ClassLeader.name.to_sym, person: person, event: event)
          event.update!(coach_id: people(:al_berchtold).id, leader_id: people(:al_schekka).id)
        end

        it 'does not show failing validation' do
          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end

        it 'does not show success message' do
          fill_in_required_columns(event)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end

        it 'does not show message after the camp has been submitted' do
          fill_in_required_columns(event)
          event.update(camp_submitted_at: Time.zone.now.to_date)

          get :show, params: { group_id: event.groups.first.id, id: event.id }
          expect(flash[:warn]).to be_blank
          expect(flash[:notice]).to be_blank
        end
      end

    end
  end

  context 'GET show_camp_application' do
    let(:event) { events(:schekka_camp) }

    context 'when authorized' do
      before { sign_in(people(:bulei)) }

      it 'renders pdf' do
        get :show_camp_application, params: { group_id: event.groups.first.id, id: event.id }
        expect(response).to be_ok
      end

      it 'renders pdf for campy course' do
        event = Fabricate(:course, kind: event_kinds(:fut))
        get :show_camp_application, params: { group_id: event.groups.first.id, id: event.id }
        expect(response).to be_ok
      end

    end

    context 'when unauthorized' do

      before { sign_in(people(:al_berchtold)) }

      it 'raises 401' do
        expect do
          get :show_camp_application, params: { group_id: event.groups.first.id, id: event.id }
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
        put :create_camp_application, params: { group_id: group.id, id: event.id }
        expect(response).to redirect_to(group_event_path(group, event))
        expect(flash[:alert]).to match /Das Lager konnte nicht eingereicht werden:/
        expect(flash[:alert]).to match /Kanton.* muss ausgefüllt werden/
        expect(event.reload).not_to be_camp_submitted
      end

      it 'sends mail if all is present' do
        group = event.groups.first
        event.update!(required_attrs_for_camp_submit)

        mail = double('mail', deliver_later: nil)
        expect(Event::CampMailer).to receive(:submit_camp).and_return(mail)

        put :create_camp_application, params: { group_id: group.id, id: event.id }
        expect(response).to redirect_to(group_event_path(group, event))
        expect(event.reload.camp_submitted_at).to eq Time.zone.now.to_date
        expect(flash[:notice]).to match /eingereicht/
        expect(event.reload).to be_camp_submitted
      end

      it 'can still submit camp when adding a supercamp' do
        group = event.groups.first
        event.update!(required_attrs_for_camp_submit)
        event.move_to_child_of(events(:bund_supercamp))

        put :create_camp_application, params: { group_id: group.id, id: event.id }
        expect(response).to redirect_to(group_event_path(group, event))
        expect(event.reload.camp_submitted_at).to eq Time.zone.now.to_date
        expect(flash[:notice]).to match /eingereicht/
        expect(event.reload).to be_camp_submitted
      end

      context 'for campy course' do
        let(:event) { Fabricate(:course, kind: event_kinds(:fut)) }

        before { event.update!(leader_id: people(:bulei).id) }

        it 'fails if no canton given' do
          group = event.groups.first
          put :create_camp_application, params: { group_id: group.id, id: event.id }
          expect(response).to redirect_to(group_event_path(group, event))
          expect(flash[:alert]).to match /Das Lager konnte nicht eingereicht werden:/
          expect(flash[:alert]).to match /Kanton.* muss ausgefüllt werden/
          expect(event.reload).not_to be_camp_submitted
        end

        it 'sends mail if all is present' do
          group = event.groups.first
          event.update!(required_attrs_for_camp_submit)

          mail = double('mail', deliver_later: nil)
          expect(Event::CampMailer).to receive(:submit_camp).and_return(mail)

          put :create_camp_application, params: { group_id: group.id, id: event.id }
          expect(response).to redirect_to(group_event_path(group, event))
          expect(flash[:alert]).to be_nil
          expect(flash[:notice]).to match /eingereicht/
          expect(event.reload).to be_camp_submitted
        end
      end

      def required_attrs_for_camp_submit
        { canton: 'be',
          location: 'foo',
          coordinates: '42',
          altitude: '1001',
          emergency_phone: '080011',
          landlord: 'georg',
          coach_confirmed: true,
          lagerreglement_applied: true,
          kantonalverband_rules_applied: true,
          j_s_rules_applied: true,
          expected_participants_pio_f: 3
        }
      end
    end

    context 'when unauthorized' do

      before { sign_in(people(:bulei)) }

      it 'raises 401' do
        expect do
          put :create_camp_application, params: { group_id: event.groups.first.id, id: event.id }
        end.to raise_error(CanCan::AccessDenied)
      end
    end

  end

  context 'camp leader checkpoint attrs' do

    let(:camp) { events(:schekka_camp) }
    before { sign_in(people(:bulei)) }

    it 'is not possible for non camp leader user to update checkpoint attrs' do
      put :update, params: { group_id: camp.groups.first.id, id: camp.id, event: checkpoint_values }

      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
        expect(camp.send(attr)).to be false
      end
    end

    it 'is possible for camp leader to update checkpoint attrs' do
      camp.leader_id = people(:bulei).id
      camp.save!

      put :update, params: { group_id: camp.groups.first.id, id: camp.id, event: checkpoint_values }

      camp.reload
      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
        expect(camp.send(attr)).to be true
      end
    end

    context 'campy course' do
      let(:event) { Fabricate(:course, kind: event_kinds(:fut)) }

      it 'is not possible for non camp leader user to update checkpoint attrs' do
        put :update, params: { group_id: event.groups.first.id, id: event.id, event: checkpoint_values }

        Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
          expect(event.send(attr)).to be false
        end
      end

      it 'is possible for camp leader to update checkpoint attrs' do
        event.leader_id = people(:bulei).id
        event.save!

        put :update, params: { group_id: event.groups.first.id, id: event.id, event: checkpoint_values }

        event.reload
        Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
          expect(event.send(attr)).to be true
        end
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

  context 'merging data from selected supercamp' do

    let(:camp) { events(:schekka_camp) }
    let(:course) { events(:top_course) }
    let(:campy_course) { Fabricate(:course, kind: event_kinds(:fut)) }
    let(:event) { events(:top_event) }
    let(:entry) { controller.send(:entry) }
    before do
      sign_in(people(:bulei))
      allow(controller).to receive(:flash).and_return(event_with_merged_supercamp: {
        name: 'Hierarchisches Lager: Schekka',
        dates_attributes: [{ location: 'Linth-Ebene' }]
      })
    end

    it 'merges data from flash for camp' do
      get :edit, params: { group_id: camp.groups.first.id, id: camp.id }
      expect(entry.name).to eq('Hierarchisches Lager: Schekka')
      expect(entry.dates.map(&:location)).to include('Linth-Ebene')
    end

    [:course, :campy_course, :event].each do |event_type|

      it 'does not merge for ' + event_type.to_s do
        e = send(event_type)
        get :edit, params: { group_id: e.groups.first.id, id: e.id }
        expect(entry.name).not_to eq('Hierarchisches Lager: Schekka')
        expect(entry.dates.map(&:location)).not_to include('Linth-Ebene')
      end

    end

  end

  context 'update the pass_on_to_supercamp flag on questions' do
    let(:event) { events(:schekka_camp) }
    let(:group) { event.groups.first }
    let!(:q1) { Fabricate(:question, id: 1, event: event, pass_on_to_supercamp: false) }
    let!(:q2) { Fabricate(:question, id: 2, event: event, admin: true, pass_on_to_supercamp: false) }
    before { sign_in(people(:al_schekka)) }

    {application_questions: 1, admin_questions: 2}.each do |attr, qid|
      it attr do
        put :update, params: { group_id: group.id, id: event.id, event: {
          (attr.to_s + '_attributes') => [ { id: qid, pass_on_to_supercamp: true } ]
        } }
        expect(event.reload.send(attr)[0].pass_on_to_supercamp).to be_truthy
      end
    end
  end

  context 'mark contact attributes to be passed on to supercamp' do

    let(:event) { events(:schekka_camp) }
    let(:group) { event.groups.first }

    before { sign_in(people(:al_schekka)) }

    it 'assigns contact_attributes_passed_on_to_supercamp' do

      put :update, params: { group_id: group.id, id: event.id, event: { contact_attrs_passed_on_to_supercamp: {
            first_name: '1', nickname: '1', address: '1', social_accounts: '1' } } }

      expect(event.reload.contact_attrs_passed_on_to_supercamp).to include('first_name')
      expect(event.contact_attrs_passed_on_to_supercamp).to include('nickname')
      expect(event.contact_attrs_passed_on_to_supercamp).to include('address')
      expect(event.contact_attrs_passed_on_to_supercamp).to include('social_accounts')

    end

    it 'removes contact_attributes_passed_on_to_supercamp' do

      event.update!({ contact_attrs_passed_on_to_supercamp:
                        ['first_name', 'social_accounts', 'address', 'nickname']})

      put :update, params: { group_id: group.id, id: event.id, event: { contact_attrs_passed_on_to_supercamp: { nickname: '1' } } }

      expect(event.reload.contact_attrs_passed_on_to_supercamp).not_to include('first_name')
      expect(event.contact_attrs_passed_on_to_supercamp).to include('nickname')
      expect(event.contact_attrs_passed_on_to_supercamp).not_to include('address')
      expect(event.contact_attrs_passed_on_to_supercamp).not_to include('social_accounts')

    end
  end

  context 'camps' do

    context 'GET index' do

      let(:token) { service_tokens(:rejected_top_group_token) }
      let(:group) { groups(:bund) }
      let!(:camp) { Fabricate(:pbs_camp, groups: [group]) }
      let!(:date) { Fabricate(:event_date, event: camp) }

      context 'without token' do
        it 'renders camps json with dates' do
          get :index, params: { type: Event::Camp.name, group_id: group.id }, format: :json
          json = JSON.parse(@response.body)

          expect(json['events']).to be_nil
          expect(json['error']).to eq('Du musst Dich anmelden oder registrieren, bevor Du fortfahren kannst.')
        end
      end

      context 'not allowed' do
        it 'renders camps json with dates' do
          get :index, params: { type: Event::Camp.name, group_id: group.id, token: token.token }, format: :json
          json = JSON.parse(@response.body)

          expect(json['events']).to be_nil
          expect(json['error']).to eq('Sie sind nicht berechtigt, diese Seite anzuzeigen')
        end
      end

      context 'allowed' do

        before do
          token.update!(events: true, token: 'Accepted')
        end

        it 'renders camps json with dates' do
          get :index, params: { type: Event::Camp.name, group_id: group.id, token: token.token }, format: :json
          json = JSON.parse(@response.body)

          event = json['events'].find { |e| e['id'] == camp.id.to_s }
          expect(event['name']).to eq('Eventus')
          expect(event['links']['dates'].size).to eq(2)
          expect(event['links']['groups'].size).to eq(1)

          expect(json['current_page']).to eq(1)
          expect(json['total_pages']).to eq(1)
          expect(json['prev_page_link']).to be_nil
          expect(json['next_page_link']).to be_nil
        end

      end

    end

  end
end
