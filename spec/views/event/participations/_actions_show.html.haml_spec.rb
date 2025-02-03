#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe "event/participations/_actions_show.html.haml" do
  let(:participation) { event_participations(:top_participant).decorate }
  let(:participant) { participation.person }
  let(:event) { participation.event }
  let(:group) { event.groups.first }
  let(:dom) { Capybara::Node::Simple.new(rendered) }

  before do
    allow(controller).to receive(:current_user).and_return(participant)
    controller.request.path_parameters[:event_id] = event.id
    controller.request.path_parameters[:group_id] = group.id
    controller.request.path_parameters[:id] = participation.id
    controller.request.path_parameters[:action] = "show"
    allow(view).to receive(:entry).and_return(participation)
    allow(view).to receive(:course_confirmation_form).and_return("Kursbestätigung")
    assign(:event, event)
    assign(:group, group)
  end

  context "confirmation action button depends on has_confirmation status" do
    it "displays confirmation button" do
      allow(participation).to receive(:has_confirmation?).and_return(true)
      render
      expect(dom).to have_content "Kursbestätigung"
    end

    it "does not display confirmation button" do
      allow(participation).to receive(:has_confirmation?).and_return(false)
      render
      expect(dom).not_to have_content "Kursbestätigung"
    end
  end
end
