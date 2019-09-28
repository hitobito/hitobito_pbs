# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::QualificationsController do

  let(:group) { course.groups.first }
  let(:course) { Fabricate(:pbs_course, groups: [groups(:bund)]) }

  before { sign_in(people(:bulei)) }

  context 'course confirmation checkbox' do

    before do
      course.update_attributes(has_confirmations: false)
    end

    it 'saves course confirmation setting' do
      put :update,
          group_id: group.id,
          event_id: course.id,
          has_confirmations: 1
      expect(course.reload.has_confirmations).to be_truthy

      put :update,
          group_id: group.id,
          event_id: course.id
      expect(course.reload.has_confirmations).to be_falsey
    end

    it 'checks permission when updating course confirmation setting' do
      sign_in(people(:al_schekka))

      expect { put :update,
                   group_id: group.id,
                   event_id: course.id,
                   has_confirmations: 1 }.to raise_exception
      expect(course.reload.has_confirmations).to be_falsey
    end

  end

  context 'course confirmation info email' do

    before do
      Fabricate(:event_participation, event: course, qualified: true, state: :assigned,
                                      roles: [Event::Course::Role::Leader.new])
      Fabricate(:event_participation, event: course, qualified: true, state: :tentative,
                                      roles: [Event::Course::Role::Participant.new])
      Fabricate(:event_participation, event: course, qualified: false, state: :assigned,
                                      roles: [Event::Course::Role::Participant.new])
      Fabricate(:event_participation, event: course, qualified: true, state: :assigned,
                                      roles: [Event::Course::Role::Participant.new])
      Fabricate(:event_participation, event: course, qualified: true, state: :assigned,
                                      roles: [Event::Course::Role::Helper.new,
                                              Event::Course::Role::Participant.new])
    end

    it 'sends email to all qualified participants' do
      expect(Event::Course::ConfirmationMailer).to receive(:notify).exactly(2).times
                                                     .and_call_original
      xhr :post, :send_confirmation_notifications, group_id: group.id, event_id: course.id
    end

    it 'checks permission' do
      sign_in(people(:al_schekka))
      expect {
        xhr :post, :send_confirmation_notifications, group_id: group.id, event_id: course.id
      }.to raise_error(CanCan::AccessDenied)
    end

  end

end
