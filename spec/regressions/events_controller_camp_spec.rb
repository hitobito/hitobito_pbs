# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventsController, type: :controller do
  render_views

  let(:dom) { Capybara::Node::Simple.new(response.body) }
  let(:camp) { Fabricate(:pbs_camp, groups: [groups(:bund)]) }
  let(:group) { camp.groups.first }
  let(:bulei) { people(:bulei) }

  context 'show restricted roles' do

    it 'creates links for restricted role people' do
      advisor_mountain = Fabricate(Group::Bund::Coach.name.to_sym, group: groups(:bund)).person
      camp.update_attribute(:advisor_mountain_security_id, advisor_mountain.id)

      sign_in(bulei)

      get :show, group_id: group.id, id: camp.id

      advisor_mountain_link = person_path(id: advisor_mountain)
      expect(dom.find_link(advisor_mountain.to_s)[:href]).to eq advisor_mountain_link
    end

    it 'only displays person\'s name if no access to show site' do
      advisor_mountain = Fabricate(Group::Bund::Coach.name.to_sym, group: groups(:bund)).person
      camp.update_attribute(:advisor_mountain_security_id, advisor_mountain.id)

      participation = Fabricate(:event_participation, event: camp)
      Fabricate(Event::Camp::Role::Helper.name.to_sym, participation: participation)
      participant = participation.person
      sign_in(participant)

      get :show, group_id: group.id, id: camp.id

      expect(dom).to have_no_selector('dl a', text: advisor_mountain.to_s)
      expect(dom).to have_selector('dl dd', text: advisor_mountain.to_s)
    end

    def find_node_for_field(dom, key)
      dom.find('dl dt',
               text: /^#{Event::Camp.human_attribute_name(key)}$/)
         .find(:xpath, 'following-sibling::*[1]')
    end

    def assert_advisor(advisor_key, text, warning)
      get :show, group_id: group.id, id: camp.id

      node = find_node_for_field(dom, advisor_key)
      expect(node.text).to eq(text)
      if warning
        expect(node).to have_selector('.label-warning')
      else
        expect(node).not_to have_selector('.label-warning')
      end
    end

    describe 'coach/abeilungsleitung warnings' do
      before do
        camp.participations.destroy_all
        sign_in(bulei)
      end

      %w(abteilungsleitung coach).each do |key|
        context key do
          it 'is marked as unassigned if not set' do
            assert_advisor(key, "Niemand zugeordnet\n", true)
          end

          it 'is marked as assigned if set' do
            camp.update_attribute("#{key}_id", bulei.id)

            text = bulei.to_s
            text += "\nNicht bestätigt\nBesucht das Lager nicht\n" if key == 'coach'
            text += "\nNicht im Lager anwesend\nBesucht das Lager nicht\n" if key == 'abteilungsleitung'
            assert_advisor(key, text, false)
          end
        end
      end
    end

    describe 'advisor warnings' do
      before do
        camp.participations.destroy_all
        sign_in(bulei)
      end

      context 'security flags not set' do
        context 'no security leaders assigned' do
          %w(advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
            context key do
              it 'is marked as unassigned if advisor not set' do
                camp.participations.destroy_all
                assert_advisor(key, '(niemand)', false)
              end

              it 'is marked as assigned if advisor set' do
                camp.update_attribute("#{key}_id", bulei.id)
                assert_advisor(key, bulei.to_s, false)
              end
            end
          end
        end

        context 'security leaders assigned' do
          before do
            [Event::Camp::Role::LeaderMountainSecurity, Event::Camp::Role::LeaderSnowSecurity,
             Event::Camp::Role::LeaderWaterSecurity].each do |role|
              Fabricate(role.name.to_sym, participation: Fabricate(:event_participation, event: camp))
            end
          end

          %w(advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
            context key do
              it 'is marked as unassigned if advisor not set' do
                camp.participations.destroy_all
                assert_advisor(key, '(niemand)', false)
              end

              it 'is marked as assigned if advisor set' do
                camp.update_attribute("#{key}_id", bulei.id)
                assert_advisor(key, bulei.to_s, false)
              end
            end
          end
        end
      end

      context 'security flags set' do
        before do
          camp.update_attributes!(j_s_security_mountain: true,
                                 j_s_security_snow: true,
                                 j_s_security_water: true)
        end

        context 'no security leaders assigned' do
          %w(advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
            context key do
              it 'is marked as unassigned if advisor not set' do
                camp.participations.destroy_all
                assert_advisor(key, 'Niemand zugeordnetKeine Leitenden erfasst', true)
              end

              it 'is marked as assigned if advisor set but with leader warning' do
                camp.update_attribute("#{key}_id", bulei.id)
                assert_advisor(key, "#{bulei.to_s}Keine Leitenden erfasst", true)
              end
            end
          end
        end

        context 'security leaders assigned' do
          before do
            [Event::Camp::Role::LeaderMountainSecurity, Event::Camp::Role::LeaderSnowSecurity,
             Event::Camp::Role::LeaderWaterSecurity].each do |role|
              Fabricate(role.name.to_sym, participation: Fabricate(:event_participation, event: camp))
            end
          end

          %w(advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
            context key do
              it 'is marked as unassigned if advisor not set' do
                camp.participations.destroy_all
                assert_advisor(key, 'Niemand zugeordnet', true)
              end

              it 'is marked as assigned if advisor set' do
                camp.update_attribute("#{key}_id", bulei.id)
                assert_advisor(key, bulei.to_s, false)
              end
            end
          end
        end
      end

    end

  end

  context 'show details' do

    let(:child) { people(:child) }
    let(:camp_leader) { people(:al_schekka) }
    let (:detail_attrs) do
      [:canton, :coordinates,
       :altitude, :emergency_phone,
       :advisor_mountain_security_id,
       :landlord, :landlord_permission_obtained,
       :j_s_kind, :local_scout_contact_present,
       :local_scout_contact, :location
      ]
    end

    before do
      child_participation = Fabricate(:pbs_participation, event: camp, person: child)
      Fabricate(Event::Camp::Role::Participant.name, participation: child_participation)
      leader_participation = Fabricate(:pbs_participation, event: camp, person: camp_leader)
      Fabricate(Event::Camp::Role::Leader.name, participation: leader_participation)

      update_camp_attrs
    end

    it 'does not show details to person with participant role' do
      sign_in(child)

      get :show, group_id: group.id, id: camp.id

      detail_attrs.each do |attr| 
        assert_no_attr(attr)
      end

      expect(dom).not_to have_selector('h2', text: 'Erwartete Teilnehmer/-innen')
      expect(dom).not_to have_selector('dt', text: 'Durchgeführt von')
    end

    it 'shows details to person with event leader role' do
      sign_in(camp_leader)

      get :show, group_id: group.id, id: camp.id

      detail_attrs.each do |attr| 
        assert_attr(attr)
      end

      expect(dom).to have_selector('h2', text: 'Erwartete Teilnehmer/-innen')
      expect(dom).to have_selector('dt', text: 'Durchgeführt von')
    end

    it 'shows details to person with update permission' do
      sign_in(bulei)

      get :show, group_id: group.id, id: camp.id

      detail_attrs.each do |attr| 
        assert_attr(attr)
      end

      expect(dom).to have_selector('h2', text: 'Erwartete Teilnehmer/-innen')
      expect(dom).to have_selector('dt', text: 'Durchgeführt von')
    end

    def assert_attr(attr)
      label = camp_attr_label(attr)
      expect(dom).to have_selector('dt', text: label)
    end

    def assert_no_attr(attr)
      label = camp_attr_label(attr)
      expect(dom).not_to have_selector('dt', text: label)
    end

    def camp_attr_label(attr)
      event_attr_label = I18n.t('activerecord.attributes.event.' + attr.to_s)
      I18n.t('activerecord.attributes.event/camp.' + attr.to_s, default: event_attr_label)
    end

    def update_camp_attrs
      camp.update_attribute(:expected_participants_wolf_f, 33)
      camp.update_attribute(:canton, 'zz')
      camp.update_attribute(:coordinates, '34')
      camp.update_attribute(:altitude, '344')
      camp.update_attribute(:emergency_phone, '344')
      camp.update_attribute(:advisor_mountain_security_id, people(:bulei).id)
      camp.update_attribute(:landlord, 'foo')
      camp.update_attribute(:j_s_kind, 'j_s_child')
      camp.update_attribute(:local_scout_contact_present, true)
      camp.update_attribute(:local_scout_contact, 'foo guy')
      camp.update_attribute(:location, 'foo place')
    end
  end

  context 'crisis_team_members' do

    let(:camp_leader) { people(:al_schekka) }
    let(:camp) { Fabricate(:pbs_camp, groups: [groups(:bern)]) }
    let(:outside_camp) { Fabricate(:pbs_camp, groups: [groups(:zuerich)]) }
    let(:canton) {groups(:be)}

    before do
      sign_in(people(:be_crisis_member))
    end

    context 'for camps from own canton' do
      before do
        leader_participation = Fabricate(:pbs_participation, event: camp, person: camp_leader)
        Fabricate(Event::Camp::Role::Leader.name, participation: leader_participation)
      end

      it 'show contact details of camp leader' do
        get :show, group_id: group.id, id: camp.id
        expect(dom).to have_selector('a', text: camp_leader.email)
      end

      it 'shows nothing if no leader is assigned' do
        camp.participations.destroy_all
        get :show, group_id: group.id, id: camp.id
        expect(dom).not_to have_selector('a', text: camp_leader.email)
      end
    end

    context 'for camp of other cantons' do
      before do
        leader_participation = Fabricate(:pbs_participation, event: outside_camp, person: camp_leader)
        Fabricate(Event::Camp::Role::Leader.name, participation: leader_participation)
      end

      it 'does not show contact details of camp leaders' do
        get :show, group_id: outside_camp.group_ids.first, id: outside_camp.id
        expect(dom).not_to have_selector('a', text: camp_leader.email)
      end

      it 'show contact details if camp is located in own canton' do
        outside_camp.update!(canton: 'be')
        canton.update!(cantons: ['be'])

        get :show, group_id: outside_camp.group_ids.first, id: outside_camp.id
        expect(dom).to have_selector('a', text: camp_leader.email)
      end
    end

  end

  context 'camp leader checkpoint attrs' do

    before { sign_in(bulei) }

    it 'checkpoint checkboxes are disabled for non camp leader user' do
      get :edit, group_id: group.id, id: camp.id

      expect(dom).to have_selector('input#event_lagerreglement_applied[disabled=disabled]')
      expect(dom).to have_selector('input#event_j_s_rules_applied[disabled=disabled]')
      expect(dom).to have_selector('input#event_kantonalverband_rules_applied[disabled=disabled]')
    end

    it 'checkpoint checkboxes to camp leader user' do
      camp.update!(leader_id: people(:bulei).id)

      get :edit, group_id: group.id, id: camp.id

      expect(dom).not_to have_selector('input#event_lagerreglement_applied[disabled=disabled]')
      expect(dom).to have_selector('input#event_lagerreglement_applied')
      expect(dom).not_to have_selector('input#event_j_s_rules_applied[disabled=disabled]')
      expect(dom).to have_selector('input#event_j_s_rules_applied')
      expect(dom).not_to have_selector('input#event_kantonalverband_rules_applied[disabled=disabled]')
      expect(dom).to have_selector('input#event_kantonalverband_rules_applied')
    end

    it 'shows checkpoint values' do
      get :show, group_id: group.id, id: camp.id

      expect(dom).to have_selector('span', text: 'Lagerreglement berücksichtigt/eingehalten: nein')
      expect(dom).to have_selector('span', text: 'Vorschriften Kantonalverband berücksichtigt/eingehalten: nein')
      expect(dom).to have_selector('span', text: 'J+S-Lager Vorschriften berücksichtigt/eingehalten: nein')
    end
  end

  context 'submit camp button' do

    before { sign_in(bulei) }

    it 'not shown if not coach user' do
      get :show, group_id: group.id, id: camp.id

      expect(dom).not_to have_selector('a', text: 'Einreichen')
      expect(dom).not_to have_selector('a.disabled', text: 'Eigereicht')
    end

    it 'is shown to coach user if camp not submitted' do
      camp.update!(coach_id: people(:bulei).id)

      get :show, group_id: group.id, id: camp.id

      expect(dom).to have_selector('a', text: 'Einreichen')
    end

    it 'is disabled if coach user and camp submitted' do
      camp.update!(coach_id: people(:bulei).id)
      submit_camp(camp)

      get :show, group_id: group.id, id: camp.id

      expect(dom).to have_selector('a.disabled', text: 'Eingereicht')
    end

    def submit_camp(camp)
      camp.update!(leader_id: Fabricate(:person).id)
      camp.update!(required_camp_attributes_for_submit)
      expect(camp.reload).to be_valid
    end

    def required_camp_attributes_for_submit
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
        expected_participants_pio_f: 3,
        camp_submitted: true
      }
    end
  end
end
