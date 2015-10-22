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

    %w(abteilungsleitung coach advisor_mountain_security advisor_snow_security advisor_water_security).each do |key|
      context key do
        it 'is marked as unassigned if not set' do
          sign_in(bulei)

          get :show, group_id: group.id, id: camp.id

          coach_node = dom.find('.dl-horizontal dt',
                                text: /^#{Event::Camp.human_attribute_name(key)}$/)
                          .find(:xpath, 'following-sibling::*[1]')
          expect(coach_node.text).to eq('nicht zugeordnet')
          expect(coach_node).to have_selector('.label-warning')
        end

        it 'is marked as assigned if set' do
          sign_in(bulei)
          camp.update_attribute("#{key}_id", bulei.id)

          get :show, group_id: group.id, id: camp.id

          value_node = dom.find('.dl-horizontal dt',
                                text: /^#{Event::Camp.human_attribute_name(key)}$/)
                          .find(:xpath, 'following-sibling::*[1]')
          text = bulei.to_s
          text += ', bestätigt: nein' if key == 'coach'
          expect(value_node.text).to eq(text)
          expect(value_node).not_to have_selector('.label-warning')
        end
      end
    end


  end

end
