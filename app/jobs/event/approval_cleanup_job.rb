# frozen_string_literal: true

#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Clean the text-comments to approvals made for event-applications
class Event::ApprovalCleanupJob < RecurringJob
  run_every 1.day

  def perform_internal
    clean_approval_comments(approval_ids)
  end

  def cutoff_date = 3.months.ago

  def approval_ids
    approvals.pluck(:id)
  end

  def clean_approval_comments(ids) # rubocop:disable Metrics/MethodLength
    return if ids.blank?

    Event::Approval
      .where(id: ids)
      .update_all( # rubocop:disable Rails/SkipsModelValidations
        comment: nil,
        current_occupation: nil,
        current_level: nil,
        occupation_assessment: nil,
        strong_points: nil,
        weak_points: nil
      )
  end

  private

  # TODO: move this into Event::Date?
  def old_events
    Event::Date
      .select(:event_id, :finish_at, :start_at)
      .from(Event::Date
              .select(:event_id).select("MAX(finish_at) AS finish_at, MAX(start_at) AS start_at")
              .joins(:event).where(events: {state: "closed"})
              .group(:event_id))
      .where("COALESCE(finish_at, start_at) < ?", cutoff_date)
  end

  def approvals
    Event::Approval.joins(participation: :event)
      .where(participations_of_old_events_condition)
      .where(approvals_with_comments_condition)
  end

  def participations_of_old_events_condition
    "event_participations.event_id IN (SELECT event_id FROM (#{old_events.to_sql}) AS old_events)"
  end

  def approvals_with_comments_condition
    <<~SQL.squish
      (
        comment IS NOT NULL OR
        current_occupation IS NOT NULL OR
        current_level IS NOT NULL OR
        occupation_assessment IS NOT NULL OR
        strong_points IS NOT NULL OR
        weak_points IS NOT NULL
      )
    SQL
  end
end
