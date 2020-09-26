# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe GroupsController, type: :controller do
  render_views

  let(:dom) { Capybara::Node::Simple.new(response.body) }
  let(:bund) { groups(:bund) }
  let(:person) { people(:child) }

  [ %w(bund Geschaeftsleitung),
    %w(be Kantonsleitung),
    %w(bern Regionalleitung),
    %w(patria Abteilungsleitung) ].each do |name, role|

      it "renders Empfehlungen tab for #{role} in #{name}" do
        group = groups(name)
        Fabricate("#{group.type}::#{role}", group: group, person: person)

        sign_in(person)
        get :show, params: { id: groups(name).id }
        expect(dom).to have_link 'Kursfreigaben (0)'
      end
    end

  it "does not render Empfehlungen tab for Bund::Geschaeftsleitung in Region Bern" do
    Fabricate("Group::Bund::Geschaeftsleitung", group: groups(:bund), person: person)

    sign_in(person)
    get :show, params: { id: groups(:be).id }
    expect(dom).not_to have_link 'Kursfreigaben'
  end

  context 'crisis' do
    let(:group)  { groups(:schekka) }
    let(:person) { Fabricate(Group::Bund::MitgliedKrisenteam.name.to_sym, group: groups(:bund)).person }
    before       { sign_in(person); crises(:schekka).update(created_at: 1.day.ago) }

    it 'renders crisis done acknowledged button if acknowledgedable active crisis exists' do
      get :show, params: { id: group.id }
      expect(dom).to have_link 'Krise quittieren'
    end

    it 'hides crisis done acknowledged button if active crisis may not be acknoledged by user' do
      group.active_crisis.update(creator: person)
      get :show, params: { id: group.id }
      expect(dom).not_to have_link 'Krise quittieren'
      expect(dom).to have_content "#{person.full_name} hat auf dieser Gruppe eine Krise ausgelöst"
    end

    it 'it renders crisis trigger button if no active crisis exists' do
      group.active_crisis.destroy
      get :show, params: { id: group.id }
      expect(dom).to have_link 'Krise'
    end
  end

end
