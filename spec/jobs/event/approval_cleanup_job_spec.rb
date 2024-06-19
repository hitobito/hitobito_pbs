# frozen_string_literal: true

#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ApprovalCleanupJob do
  include ActiveJob::TestHelper # use a dedicated queue for tests

  subject(:job) { described_class.new }

  def create_approval(event_finish: 4.months.ago, event_start: event_finish)
    start = event_start&.change(hour: 8)
    finish = event_finish&.change(hour: 18)

    application = Fabricate(:pbs_application)
    application.create_participation(
      event: application.priority_1,
      person: people(:al_schekka),
      active: true,
      state: 'assigned',
      j_s_data_sharing_accepted_at: [start, finish, 1.year.ago].compact.first - 1.week
    )

    event = application.participation.event
    event.dates.clear
    event.dates << Fabricate(
      :event_date,
      start_at: start,
      finish_at: finish
    )
    event.state = 'closed'
    event.save!

    Event::Approval.create(
      application: application,
      layer: 'bund',
      approved: true,

      approver: people(:bulei),

      comment: 'kann man schon so machen',
      current_occupation: 'chef vons ganze',
      current_level: '42',
      occupation_assessment: 'is ganz der chef',
      strong_points: 'weiß, dass eigentlich die anderen schuld sind',
      weak_points: 'ist selbst schuld'
    )
  end

  it 'is scheduled daily' do
    expect(job.interval).to eql 1.day
  end

  it 'knows its cutoff-date' do
    expect(job.cutoff_date).to be_within(1.day).of(3.months.ago)
  end

  it 'knows the approvals to clean' do
    # old events
    create_approval(event_finish: 4.months.ago)
    create_approval(event_start: 5.months.ago, event_finish: nil)

    # new events
    create_approval(event_finish: 2.months.ago)
    create_approval(event_start: 1.month.ago, event_finish: nil)

    # overlapping, but not yet old event
    approval = create_approval(event_finish: 5.months.ago)
    event = approval.application.participation.event
    event.dates << Fabricate(:event_date, start_at: 1.month.ago)

    expect(job.approval_ids).to have(2).item
  end

  it 'does not consider already cleaned approvals' do
    create_approval(event_finish: 4.months.ago)

    expect do
      job.perform
    end.to change { job.approval_ids.count }.from(1).to(0)
  end

  {
    comment: 'kann man schon so machen',
    current_occupation: 'chef vons ganze',
    current_level: '42',
    occupation_assessment: 'is ganz der chef',
    strong_points: 'weiß, dass eigentlich die anderen schuld sind',
    weak_points: 'ist selbst schuld'
  }.each do |attr, old_value|
    it "cleans the column #{attr} of the approval" do
      approval = create_approval(event_finish: 4.months.ago)

      expect do
        job.perform
        approval.reload
      end.to(change(approval, attr).from(old_value).to(nil))
    end
  end

  it 'cleans after the cutoff-date' do
    create_approval(event_finish: 4.months.ago)
    expect(job.approval_ids).to have(1).item
  end

  it 'does not clean before the cutoff-date' do
    create_approval(event_finish: 2.months.ago)
    expect(job.approval_ids).to have(0).items
  end
end
