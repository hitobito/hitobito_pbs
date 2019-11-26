#  Copyright (c) 2019 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe SupercampsController do

  let!(:supercamp_dates) { event_dates(:sixth, :sixth_two) }
  let!(:supercamp_application_questions) { Fabricate(:question, event: supercamp) }
  let!(:supercamp_admin_questions) { Fabricate(:question, admin: true, event: supercamp) }
  let!(:supercamp) { events(:bund_supercamp) }

  before do
    sign_in(people(:al_schekka))
  end

  describe 'find available supercamps' do
    let!(:supercamp_schekka) do
      Fabricate(:event, type: Event::Camp.name, name: 'Schekka Super',
                        groups: [groups(:schekka)], allow_sub_camps: true, state: 'created')
    end
    let!(:supercamp_tsueri) do
      Fabricate(:event, type: Event::Camp.name, name: 'Tsueri Super', groups: [groups(:chaeib)],
                        allow_sub_camps: true, state: 'created')
    end
    let(:camp) { events(:schekka_camp) }
    let(:group) { camp.groups.first }

    before do
      camp.update(allow_sub_camps: true, state: 'created')
      assert_true(camp.reload.allow_sub_camps)
      assert_true(supercamp_schekka.reload.allow_sub_camps)
      assert_true(supercamp_tsueri.reload.allow_sub_camps)
    end

    context 'available' do
      let(:subject) { assigns(:supercamps_on_group_and_above).map(&:name) }

      it 'finds supercamps on group and above' do
        xhr :get, :available, group_id: group.id, camp_id: camp.id, format: :js
        is_expected.to include('Hauptlager', 'Schekka Super')
        is_expected.not_to include('Tsueri Super')
      end

      it 'excludes itself' do
        xhr :get, :available, group_id: group.id, camp_id: camp.id, format: :js
        is_expected.not_to include('Sommerlager')
      end

    end

    context 'query' do
      let(:subject) { assigns(:found_supercamps).map(&:name) }

      it 'query finds supercamps anywhere' do
        xhr :get, :query, group_id: group.id, camp_id: camp.id, q: 'sup', format: :js
        is_expected.to include('Schekka Super', 'Tsueri Super')
        is_expected.not_to include('Hauptlager')
      end

      it 'query excludes itself' do
        xhr :get, :query, group_id: group.id, camp_id: camp.id, q: 'lager', format: :js
        is_expected.not_to include('Sommerlager')
      end

      it 'does not query for less than 3 characters' do
        xhr :get, :query, group_id: group.id, camp_id: camp.id, q: 'su', format: :js
        is_expected.to be_empty
      end

    end

  end

  describe 'connect supercamp' do

    [:edit, :create].each do |form|
      context 'when coming from the ' + form.to_s + ' form' do

        let(:camp) { events(:schekka_camp) }
        let(:group) { camp.groups.first }
        let(:supercamp_allows_sub_camps) { true }
        let(:supercamp_state) { 'created' }
        let(:event_form_data) { camp.attributes }
        let(:expected_required_contact_attrs) { {'email' => :required,
                                                 'first_name' => :required,
                                                 'last_name' => :required,
                                                 'town' => :required } }
        let(:result) { controller.flash[:event_with_merged_supercamp] }

        before do
          camp.update!(al_visiting: true,
                       kantonalverband_rules_applied: true,
                       lagerreglement_applied: true,
                       coach_visiting: true,
                       j_s_rules_applied: true,
                       al_present: true)
          supercamp.update!(allow_sub_camps: supercamp_allows_sub_camps,
                            state: supercamp_state,
                            required_contact_attrs: [:town])

          request.env['HTTP_REFERER'] = '/' + form.to_s
          if form == :create
            post :connect, group_id: group.id, supercamp_id: supercamp.id, event: event_form_data
          else
            patch :connect, group_id: group.id, supercamp_id: supercamp.id, camp_id: camp.id, event: event_form_data
          end
        end

        context 'authorization' do

          context 'checks that supercamp allows subcamps' do
            let(:supercamp_allows_sub_camps) { false }
            it do
              expect(supercamp.allow_sub_camps).to be_falsey
              expect(supercamp.state).to be('created')
              expect(flash[:alert]).to eq('Das gewählte Lager erlaubt keine untergeordneten Lager')
            end
          end

          context 'checks that supercamp is in the correct state' do
            let(:supercamp_state) { 'confirmed' }
            it do
              expect(supercamp.reload.allow_sub_camps).to be_truthy
              expect(supercamp.reload.state).to be('confirmed')
              expect(flash[:alert]).to eq('Das gewählte übergeordnete Lager ist nicht im Status "Erstellt"')
            end
          end

        end

        it 'redirects back' do
          expect(response).to redirect_to('/' + form.to_s)
        end

        context 'merge supercamp data' do

          it 'name is calculated' do
            expect(supercamp.reload.allow_sub_camps).to be_truthy
            expect(response.status).to eq(302)
            expect(result).not_to be_nil
            expect(result[:name]).to eq(supercamp.name + ': ' + group.display_name)
          end

          it 'description is calculated' do
            expect(result[:description]).to eq((supercamp.description.to_s + "\n\n" + camp.description.to_s).strip)
          end

          it 'parent_id is correct' do
            expect(result[:parent_id]).to eq(supercamp.id.to_s)
          end

          it 'dates from supercamp' do
            attrs = %w(label location start_at finish_at)
            expect(result[:dates_attributes].map { |d| d.slice(attrs) })
              .to eq(supercamp.dates.map { |d| d.attributes.slice(attrs) })
          end

          it 'application questions from supercamp' do
            attrs = %w(question choices multiple_choices required)
            expect(result[:application_questions_attributes].map { |q| q.slice(attrs) })
              .to eq(supercamp.application_questions.map { |q| q.attributes.slice(attrs) })
          end

          it 'application questions have flag set' do
            expect(result[:application_questions_attributes][0][:pass_on_to_supercamp]).to be_truthy
          end

          it 'admin questions from supercamp' do
            attrs = %w(question choices multiple_choices required)
            expect(result[:admin_questions_attributes].map { |q| q.slice(attrs) })
              .to eq(supercamp.admin_questions.map { |q| q.attributes.slice(attrs) })
          end

          it 'admin questions have flag set' do
            expect(result[:admin_questions_attributes][0][:pass_on_to_supercamp]).to be_truthy
          end

          it 'required_contact_attrs from supercamp' do
            expect(result[:contact_attrs]).to eq(expected_required_contact_attrs)
          end

          it 'contact_attrs_passed_on_to_supercamp from supercamp\'s required_contact attrs' do
            expect(result[:contact_attrs_passed_on_to_supercamp]).to eq(expected_required_contact_attrs)
          end

          [
            :state, :lagerreglement_applied, :kantonalverband_rules_applied, :j_s_rules_applied,
            :leader_id, :abteilungsleitung_id, :al_present, :al_visiting, :al_visiting_date, :coach_id,
            :coach_visiting, :coach_visiting_date, :advisor_mountain_security, :advisor_snow_security,
            :advisor_water_security
          ].each do |attr|
            it attr.to_s + ' from subcamp' do
              expect(supercamp.reload.allow_sub_camps).to be_truthy
              expect(response.status).to eq(302)
              expect(result).not_to be_nil
              expect(result[attr]).to eq(camp.attributes[attr.to_s])
            end
          end

          [
            :motto, :cost, :location, :canton, :coordinates, :altitude, :emergency_phone, :landlord,
            :landlord_permission_obtained, :local_scout_contact_present, :local_scout_contact,
            :j_s_kind, :j_s_security_mountain, :j_s_security_snow, :j_s_security_water,
            :application_opening_at, :application_closing_at, :application_conditions, :maximum,
            :external_applications, :signature, :signature_confirmation, :signature_confirmation_text,
            :paper_application_required, :participants_can_apply, :participants_can_cancel
          ].each do |attr|
            it attr.to_s + ' from supercamp' do
              expect(result[attr]).to eq(supercamp.attributes[attr.to_s])
            end
          end

        end

      end

    end
  end
end
