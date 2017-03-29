# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_youth.

require 'spec_helper'

describe Event::ParticipationContactDatasController, type: :controller do

  render_views

  let(:group) { groups(:top_layer) }
  let(:course) { Fabricate(:course, groups: [group]) }
  let(:person) { people(:top_leader) }
  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(person) }

  describe 'GET edit' do

    it 'does not show hidden contact fields' do

      course.update!({ hidden_contact_attrs: ['salutation'] })

      get :edit, group_id: course.groups.first.id, event_id: course.id,
            event_role: { type: 'Event::Course::Role::Participant' }

      expect(dom).to have_selector('input#event_participation_contact_data_grade_of_school')
      expect(dom).to have_selector('input#event_participation_contact_data_title')

      expect(dom).to have_no_selector('input#event_participation_contact_data_salutation')

    end

    it 'shows all contact fields by default' do

      get :edit, group_id: course.groups.first.id, event_id: course.id,
            event_role: { type: 'Event::Course::Role::Participant' }

      contact_attrs = [:salutation, :title, :grade_of_school,
                       :entry_date, :leaving_date,
                       :correspondence_language]

      contact_attrs.each do |a|
        expect(dom).to have_selector("input#event_participation_contact_data_#{a}")
      end

    end

  end

  context 'POST update' do

    before do
      course.update!({ required_contact_attrs: ['salutation']})
    end

    it 'validates contact attributes and person attributes' do

      contact_data_params = { first_name: 'Hans', last_name: 'Gugger', email: 'hans@pbs.ch', salutation: '' }

      post :update, group_id: group.id, event_id: course.id,
             event_participation_contact_data: contact_data_params,
             event_role: { type: 'Event::Course::Role::Participant' }

      is_expected.to render_template(:edit)

      expect(dom).to have_selector('.alert-error li', text: 'Anrede muss ausgefüllt werden')

    end

    it 'updates person attributes and redirects to event questions' do

      contact_data_params = { first_name: 'Hans', last_name: 'Gugger',
                              email: 'dude@example.com', salutation: 'Dr.',
                              address: 'Street 33' }

      post :update, group_id: group.id, event_id: course.id,
             event_participation_contact_data: contact_data_params,
             event_role: { type: 'Event::Course::Role::Participant' }

      is_expected.to redirect_to new_group_event_participation_path(group,
                                                                    course,
                                                                    event_role: { type: 'Event::Course::Role::Participant' })

      person.reload
      expect(person.salutation).to eq('Dr.')

    end
  end

end
