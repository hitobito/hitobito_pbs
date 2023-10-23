# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class AlumniInvitationsJob < RecurringJob
  run_every 1.day

  def perform
    Alumni::Invitations.new.process
    Alumni::Reminders.new.process
  end
end
