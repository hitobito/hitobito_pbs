#  Copyright (c) 2019-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::QualificationsController do
  let(:group) { course.groups.first }
  let(:kind) { Fabricate(:pbs_course_kind) }
  let(:course) { Fabricate(:pbs_course, groups: [groups(:bund)], kind: kind) }

  before { sign_in(people(:bulei)) }

  context "course confirmation checkbox" do
    before do
      course.update(has_confirmations: false)
    end

    it "saves course confirmation setting" do
      put :update,
        params: {
          group_id: group.id,
          event_id: course.id,
          has_confirmations: 1
        }
      expect(course.reload.has_confirmations).to be_truthy

      put :update,
        params: {
          group_id: group.id,
          event_id: course.id
        }
      expect(course.reload.has_confirmations).to be_falsey
    end

    it "checks permission when updating course confirmation setting" do
      sign_in(people(:al_schekka))

      expect do
        put :update,
          params: {
            group_id: group.id,
            event_id: course.id,
            has_confirmations: 1
          }
      end.to raise_error CanCan::AccessDenied
      expect(course.reload.has_confirmations).to be_falsey
    end
  end

  context "course confirmation info email" do
    before do
      Fabricate(:pbs_participation, event: course, qualified: true, state: :assigned,
        roles: [Event::Course::Role::Leader.new])
      Fabricate(:pbs_participation, event: course, qualified: true, state: :tentative,
        roles: [Event::Course::Role::Participant.new])
      Fabricate(:pbs_participation, event: course, qualified: false, state: :assigned,
        roles: [Event::Course::Role::Participant.new])
      Fabricate(:pbs_participation, event: course, qualified: true, state: :assigned,
        roles: [Event::Course::Role::Participant.new])
      Fabricate(:pbs_participation, event: course, qualified: true, state: :assigned,
        roles: [Event::Course::Role::Helper.new,
          Event::Course::Role::Participant.new])
    end

    it "sends email to all qualified participants" do
      expect(Event::Course::ConfirmationMailer).to receive(:notify).twice
        .and_call_original
      post :send_confirmation_notifications, params: {group_id: group.id, event_id: course.id},
        xhr: true
    end

    it "checks permission" do
      sign_in(people(:al_schekka))
      post :send_confirmation_notifications, params: {group_id: group.id, event_id: course.id},
        xhr: true
      expect(response).to have_http_status(403)
    end
  end
end
