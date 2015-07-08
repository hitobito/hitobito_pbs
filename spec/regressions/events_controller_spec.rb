# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require_relative '../support/fabrication.rb'
describe EventsController, type: :controller  do

  render_views

  let(:dom) { Capybara::Node::Simple.new(response.body) }
  let(:bund) { groups(:bund) }
  let(:person) { people(:bulei) }
  let(:assistenz) { Fabricate(Group::Bund::AssistenzAusbildung.name.to_sym, group: bund, person: person) }

  it "MitarbeiterGS may not edit training_days and express_fee" do
    sign_in(person)
    get :edit, group_id: groups(:be).id, id: events(:top_course).id

    expect(dom).not_to have_content('Expressgebühr')
    expect(dom).not_to have_content('Ausbildungstage')
  end

  it "AssistenzAusbildung may edit training_days and express_fee" do
    sign_in(assistenz.person)
    get :edit, group_id: groups(:be).id, id: events(:top_course).id

    expect(dom).to have_content('Expressgebühr')
    expect(dom).to have_content('Ausbildungstage')
  end
end
