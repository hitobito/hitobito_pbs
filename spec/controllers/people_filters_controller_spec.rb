# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PeopleFiltersController do

  before { sign_in(people(:bulei)) }
  let(:group) { groups(:bund) }

  context 'GET#new' do
    render_views

    it 'sets education value to true if education param present' do
      get :new, group_id: group.id, education: true
      dom = Capybara::Node::Simple.new(response.body)
      expect(dom.find('input[name="education"]').value).to eq "true"
    end

    it 'sets education value to nil if education param missing' do
      get :new, group_id: group.id
      dom = Capybara::Node::Simple.new(response.body)
      expect(dom.find('input[name="education"]').value).to be_blank
    end
  end


  context 'POST#create' do
    it 'with education redirects to education' do
      post :create, group_id: group.id, education: true, people_filter: { name: 'test' }
      is_expected.to redirect_to educations_path(group)
    end

    it 'without education redirects to group_people' do
      post :create, group_id: group.id, people_filter: { name: 'test' }
      is_expected.to redirect_to group_people_path(group)
    end
  end

  context 'DELETE#destroy' do
    let!(:filter) { PeopleFilter.create!(name: 'test', group: group) }

    it 'without education redirects to group_people' do
      delete :destroy, group_id: group.id, id: filter.id
      is_expected.to redirect_to group_people_path(group)
    end

    it 'with education redirects to education' do
      delete :destroy, group_id: group.id, id: filter.id, education: true
      is_expected.to redirect_to educations_path(group)
    end
  end

end
