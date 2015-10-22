# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require_relative '../support/fabrication.rb'
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
      participant = participation.person
      sign_in(participant)

      get :show, group_id: group.id, id: camp.id

      expect(dom).to have_no_selector('.dl-horizontal a', text: advisor_mountain.to_s)
      expect(dom).to have_selector('.dl-horizontal dd', text: advisor_mountain.to_s)
    end

    def find_node_for_field(dom, key)
      dom.find('.dl-horizontal dt',
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
            assert_advisor(key, 'nicht zugeordnet', true)
          end

          it 'is marked as assigned if set' do
            camp.update_attribute("#{key}_id", bulei.id)

            text = bulei.to_s
            text += ', bestätigt: nein' if key == 'coach'
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
          camp.update_attributes(j_s_security_mountain: true,
                                 j_s_security_snow: true,
                                 j_s_security_water: true)
        end

        context 'no security leaders assigned' do
          %w(advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
            context key do
              it 'is marked as unassigned if advisor not set' do
                camp.participations.destroy_all
                assert_advisor(key, 'nicht zugeordnet', true)
              end

              it 'is marked as assigned if advisor set but with leader warning' do
                camp.update_attribute("#{key}_id", bulei.id)
                assert_advisor(key, "#{bulei.to_s} Leiter nicht zugeordnet", true)
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
                assert_advisor(key, 'nicht zugeordnet', true)
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

end
