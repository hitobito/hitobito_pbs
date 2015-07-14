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
  let(:bulei) { people(:bulei) }
  let(:al_schekka) { people(:al_schekka) }
  let(:group) { course.groups.first } # be
  let(:course) { events(:top_course) }
  let(:course_bund) { events(:bund_course) }
  let(:assistenz) { Fabricate(Group::Bund::AssistenzAusbildung.name.to_sym, group: bund, person: al_schekka) }
  let(:mitarbeiter_gs) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: bund, person: al_schekka) }
  let(:sekretar) { Fabricate(Group::Bund::Sekretariat.name.to_sym, group: bund, person: al_schekka) }

  it "MitarbeiterGS may edit training_days and express_fee" do
    sign_in(bulei)
    get :edit, group_id: group.id, id: course.id

    expect(dom).to have_content('Expressgebühr')
    expect(dom).to have_content('Ausbildungstage')
  end

  it "AssistenzAusbildung may edit training_days and express_fee" do
    sign_in(assistenz.person)
    get :edit, group_id: bund.id, id: course_bund.id

    expect(dom).to have_content('Expressgebühr')
    expect(dom).to have_content('Ausbildungstage')
  end

  # TODO implement: dont show field in view if no permission
  #it "Sekretariat may not edit training_days and express_fee" do
    #sign_in(sekretar.person)
    #get :edit, group_id: group.id, id: course.id

    #expect(dom).not_to have_content('Expressgebühr')
    #expect(dom).not_to have_content('Ausbildungstage')
  #end

  it "Sekretariat may not update training_days and express_fee" do
    sign_in(sekretar.person)
    course.update_attributes!(express_fee: '424', training_days: 42) 
    post :update, group_id: group.id, id: course.id, event: { express_fee: 909, training_days: 33 }

    course.reload
    expect(course.express_fee).to eq('424')
    expect(course.training_days).to eq(42)
  end

  it "MitarbeiterGs may update training_days and express_fee" do
    sign_in(mitarbeiter_gs.person)
    post :update, group_id: group.id, id: course.id, event: { express_fee: 909, training_days: 33 }

    course.reload
    expect(course.express_fee).to eq('909')
    expect(course.training_days).to eq(33)
  end

  # TODO check why course_bund isn't updated
  #it "AssistenzAusbildung may update training_days and express_fee" do
    #sign_in(assistenz.person)
    #post :update, group_id: bund.id, id: course_bund.id, event: { express_fee: 909, training_days: 33 }

    #course_bund.reload
    #expect(course_bund.express_fee).to eq('909')
    #expect(course_bund.training_days).to eq(33)
  #end

  it "shows 'Informieren' Button when course state is canceled" do
    sign_in(bulei)
    course.update!(state: 'canceled')
    get :show, group_id: group.id, id: course.id
    link = dom.find_link 'Informieren'
    expect(link[:href]).to eq 'mailto:bulei@hitobito.example.com, al.schekka@hitobito.example.com'
  end

end
