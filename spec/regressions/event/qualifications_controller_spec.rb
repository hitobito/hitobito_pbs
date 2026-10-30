#  Copyright (c) 2012-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_youth and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::QualificationsController, type: :controller do
  render_views

  let(:course) { events(:top_course) }
  let(:advisor) { people(:child) }
  let(:bulei) { people(:bulei) }

  before do
    sign_in(advisor)
  end

  describe "GET index" do
    context "advisor / LKB" do
      let(:page) { Capybara::Node::Simple.new(response.body).find("#page") }

      it "can view qualifications" do
        course.update!(advisor_id: advisor.id)

        get :index, params: {group_id: course.groups.first.id, event_id: course.id}

        expect(page).to have_selector("input[type=checkbox]")
      end
    end
  end
end
