# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PopulationController, type: :controller do

  render_views

  let(:dom) { Capybara::Node::Simple.new(response.body) }

  before { sign_in(people(:bulei)) }

  describe 'GET index' do

    before { get :index, id: group.id }

    context 'with existing census' do
      let(:group) { groups(:schekka) }

      it 'does not show any approveable content if there is no current census' do
        expect(dom.all('#content h2').count).to eq 3
        expect(dom).to have_no_selector('a', text: 'Bestand bestätigen')
        expect(dom).to have_no_selector('.alert.alert-info.approveable')
        expect(dom).to have_no_selector('.alert.alert-alert.approveable')
        expect(dom.find('a', text: 'Bestand')).to have_no_selector('span', text: '!')
      end
    end

    context 'without existing census' do
      let(:group) { groups(:schweizerstern) }

      it 'does show all approveable content if there is a current census' do
        expect(dom.all('#content h2').count).to eq 1
        expect(dom).to have_selector('a', text: 'Bestand bestätigen')
        expect(dom).to have_content('Bitte ergänze')
        expect(dom.all('a', text: 'Bestand').first).to have_selector('span', text: '!')
      end
    end
  end
end
