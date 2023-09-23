# frozen_string_literal: true

class AlumniInvitationsJob < RecurringJob
  run_every 1.day

  def perform
    Alumni::Invitations.new.process
    Alumni::Reminders.new.process
  end
end
