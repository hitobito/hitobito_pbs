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
        get :show, id: groups(name).id
        expect(dom).to have_link 'Freigaben'
      end
    end

  it "does not render Empfehlungen tab for Bund::Geschaeftsleitung in Region Bern" do
    Fabricate("Group::Bund::Geschaeftsleitung", group: groups(:bund), person: person)

    sign_in(person)
    get :show, id: groups(:be).id
    expect(dom).not_to have_link 'Freigaben'
  end

end
