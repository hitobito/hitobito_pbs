# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Application do

  let(:course) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk)) }
  let(:course2) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk)) }
  let(:participation) { Fabricate(:pbs_participation, person: people(:al_schekka)) }

  [true, false].each do |requires_approval|
    context requires_approval && 'approval required' || 'approval not required' do
      before do
        if requires_approval
          course.requires_approval_abteilung = requires_approval
          course.save!
        end
      end

      it 'calls Event::Approver.request_approvals on creation' do
        expect_any_instance_of(Event::Approver).to receive(:request_approvals).once
        Fabricate(:event_application, priority_1: course, priority_2: course2,
                                      participation: participation)
      end

      it 'does not call Event::Approver.request_approvals on update' do
        expect_any_instance_of(Event::Approver).to receive(:request_approvals).once
        application = Fabricate(:event_application, priority_1: course,
                                                    priority_2: course2,
                                                    participation: participation)
        application.save!
      end
    end
  end

  it 'changing approval requirement on prio 1 course calls Event::Approver.request_approvals' do
    course.update(requires_approval_abteilung: false)

    expect_any_instance_of(Event::Approver).to receive(:request_approvals).once
    Fabricate(:event_application, priority_1: course, priority_2: course2,
              participation: participation)
    course.update(requires_approval_abteilung: true)
  end

  it 'changing approval requirement on prio 2 course calls Event::Approver.request_approvals' do
    course2.update(requires_approval_abteilung: false)

    expect_any_instance_of(Event::Approver).to receive(:request_approvals).once
    Fabricate(:event_application, priority_1: course, priority_2: course2,
              participation: participation)
    course2.update(requires_approval_abteilung: true)
  end

end
