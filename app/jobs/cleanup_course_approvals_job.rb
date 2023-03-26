# frozen_string_literal: true

#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class CleanupCourseApprovalsJob < RecurringJob

  run_every 1.day

  def perform
    Event::Approval.
    joins(participation: { event: :event_dates }).
    where('event_dates.id = :last_finish',
      last_finish: Event::Date.select('id').
      where('event_id = ?', :event_date).
      order(finish_at: :desc).limit(1)).
    where(events: { state: 'closed' }).
    where('event_dates.finish_at < ?', 3.months.ago).
    update_all(comment: nil, current_occupation: nil,
        current_level: nil, occupation_assessment: nil,
        strong_points: nil, weak_points: nil)

  end
end
