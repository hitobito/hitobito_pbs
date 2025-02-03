#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe "events/_attrs.html.haml" do
  let(:bulei) { people(:bulei) }

  before do
    assign(:event, event)
    assign(:group, event.groups.first)
    allow(view).to receive_messages(action_name: "events", current_user: bulei, entry: event)
    allow(controller).to receive_messages(current_user: bulei)
    allow(controller).to receive_messages(current_person: bulei)
  end

  let(:dom) { Capybara::Node::Simple.new(rendered) }

  subject { dom }

  context "course" do
    let(:event) { EventDecorator.decorate(events(:top_course)) }

    context "kind" do
      it "shows documents_text" do
        event.kind.update!(documents_text: "some documents text")

        render
        is_expected.to have_content "some documents text"
      end

      it "shows application conditions and general information when set" do
        event.update!(application_conditions: "some application conditions")
        event.kind.update!(general_information: "some general informations")

        render
        is_expected.to have_content "some general informations"
        is_expected.to have_content "some application conditions"
      end
    end
  end
end
