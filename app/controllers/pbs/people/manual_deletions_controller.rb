module Pbs::People::ManualDeletionsController
  RECENT_EVENT_CUTOFF_DURATION = 10.years

  def ensure_universal_rules
    if participated_in_recent_event?
      @universal_errors << t(".errors.participated_in_recent_event",
        duration: RECENT_EVENT_CUTOFF_DURATION)
    end

    super
  end

  def participated_in_recent_event?
    Event.joins(:dates, :participations)
      .where("event_dates.start_at > :cutoff OR event_dates.finish_at > :cutoff",
        cutoff: RECENT_EVENT_CUTOFF_DURATION.ago)
      .where(event_participations: {participant_id: entry.id, participant_type: Person.sti_name})
      .any?
  end
end
