# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Event::CampReminderJob < RecurringJob

  RUN_AT = 3 # 3 a.m.
  SPAN_NATIONAL = 6.weeks
  SPAN_ABROAD = 10.weeks
  NOTIFIED_ROLES = [Event::Camp::Role::Leader, Event::Camp::Role::Coach].freeze

  run_every 24.hours


  def perform_internal
    with_notified_roles(camps_to_remind).find_each do |camp|
      send_reminder(camp)
    end
  end

  def camps_to_remind
    camps = Event::Camp.where(camp_submitted: false, camp_reminder_sent: false).
            where.not(state: 'created')
    starting_soon(camps)
  end

  private

  def send_reminder(camp)
    recipients = fetch_recipients(camp)
    recipients.each do |person|
      I18n.locale = person.correspondence_language.presence || I18n.default_locale
      Event::CampMailer.remind(camp, person).deliver_now
    end
    camp.update_column(:camp_reminder_sent, true) if recipients.present?
  end

  def fetch_recipients(camp)
    camp.participations.collect(&:person).
      uniq.
      select { |person| Person.mailing_emails_for(person).present? }
  end

  def starting_soon(camps)
    tonight = Time.zone.now.midnight
    camps.includes(:dates).
      references(:dates).
      where('event_dates.start_at >= ? AND (' \
                '(canton != ? AND event_dates.start_at <= ?) OR ' \
                '(canton = ? AND event_dates.start_at <= ?))',
            tonight,
            Event::Camp::ABROAD_CANTON, tonight + SPAN_NATIONAL + 1.day,
            Event::Camp::ABROAD_CANTON, tonight + SPAN_ABROAD + 1.day)
  end

  def with_notified_roles(camps)
    camps.includes(participations: [:roles, :person]).
      references(participations: :roles).
      where(event_roles: { type: NOTIFIED_ROLES })
  end

  def next_run
    job = delayed_jobs.first
    now = Time.zone.now
    if job
      [now, job.run_at + interval].max
    else
      Time.zone.local(now.year, now.month, now.day, RUN_AT) + 1.day
    end
  end

end
