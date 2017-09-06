# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require 'event/qualifications_controller'

describe Event::QualificationsController, type: :controller do

  render_views

  let(:course) { events(:top_course) }
  let(:advisor) { people(:child) }
  let(:bulei) { people(:bulei) }

  before do
    sign_in(advisor)
  end

  describe 'GET index' do

    context 'advisor / LKB' do

      let(:page) { Capybara::Node::Simple.new(response.body).find('#page') }

      it 'can view qualifications' do

        course.update!(advisor_id: advisor.id)

        get :index, group_id: course.groups.first.id, event_id: course.id

        expect(page).to have_selector('input[type=checkbox]')
      end

    end

  end

  #describe_action :get, :new do
    #context '.html', format: :html do
      #let(:page) { Capybara::Node::Simple.new(response.body).find('#page') }

      #it 'renders sheets and form' do
        #expect(page).to have_css('.sheet', count: 3)
        #sheet = page.find('.container-fluid > .sheet.parent')
        #expect(sheet.find('.breadcrumb').find_link('Top')[:href]).to eq group_path(groups(:top_layer))
        #expect(sheet.find_link('TopGroup')[:href]).to eq group_path(top_group)
        #expect(sheet.find_link('Personen')[:href]).to eq group_people_path(top_group, returning: true)
        #expect(page.find_link('Top Leader')[:href]).to eq group_person_path(top_group, top_leader)
        #nav = page.find('.nav-left')
        #expect(nav.find_link('Top')[:href]).to eq group_people_path(groups(:top_layer), returning: true)
        #expect(nav.find_link('TopGroup')[:href]).to eq group_people_path(top_group, returning: true)
        #expect(nav.find_link('Bottom One')[:href]).to eq group_people_path(groups(:bottom_layer_one), returning: true)
        #expect(nav.find_link('Bottom Two')[:href]).to eq group_people_path(groups(:bottom_layer_two), returning: true)
      #end
    #end
  #end


end
