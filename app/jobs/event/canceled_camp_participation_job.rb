# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::CanceledCampParticipationJob < BaseJob

  self.parameters = [:participation_id, :locale]

  def initialize(participation)
    super()
    @participation_id = participation.id
  end

  def perform
    return if participation.nil? || participation.state != 'canceled' # may have been deleted again

    set_locale
    send_notification
  end

  private

  def send_notification
    recipients = camp_leaders
    if recipients.present?
      Event::CampMailer.participant_canceled_info(participation, recipients).deliver_now
    end
  end

  def camp_leaders
    participation.event.people.
      joins(event_participations: :roles).
      where(event_participations: { active: true }).
      where(event_roles: { type: Event::Camp::Role::Leader.sti_name }).
      uniq.
      includes(:additional_emails)
  end

  def participation
    @participation ||= Event::Participation.where(id: @participation_id).first
  end

end


