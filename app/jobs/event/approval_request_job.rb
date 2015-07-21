# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::ApprovalRequestJob < BaseJob

  self.parameters = [:participation_id, :locale]

  def initialize(participation)
    super()
    @participation_id = participation.id
  end

  def perform
    return unless participation # may have been deleted again

    set_locale
    send_approval
  end

  def send_approval
    recipients = approvers
    if recipients.present?
      Event::ParticipationMailer.approval(participation, recipients).deliver
    end
  end

  def approvers
    approver = Event::Approver.new(participation)
    approver.current_approvers.only_public_data.to_a
  end

  def participation
    @participation ||= Event::Participation.find(@participation_id)
  end

end
