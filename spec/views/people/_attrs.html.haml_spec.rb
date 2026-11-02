#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe "people/_attrs.html.haml" do
  let(:person) { people(:al_schekka) }
  let(:current_user) { people(:bulei) }

  subject do
    render
    Capybara::Node::Simple.new(@rendered)
  end

  before do
    assign(:group, groups(:schekka))
    assign(:qualifications, [])
    assign(:tags, [])
    allow(view).to receive_messages(parent: groups(:schekka))
    allow(view).to receive_messages(entry: PersonDecorator.decorate(person))
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(view).to receive(:current_user).and_return(current_user)
  end

  it "shows person number but not PBS Personennummer" do
    is_expected.to have_xpath("//dt[normalize-space()='Personennummer']" \
      "/following-sibling::dd[1][normalize-space()='#{person.id}']")
    is_expected.not_to have_css("dt", text: "PBS Personennummer")
  end
end
