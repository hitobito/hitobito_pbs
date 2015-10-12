# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


module EventsPbsHelper

  def format_course_languages(entry)
    Event::Course::LANGUAGES.map do |key|
      attr = "language_#{key}"
      if entry.send("#{attr}?")
        I18n.t("events.fields_pbs.#{attr}")
      end
    end.compact.join(', ')
  end

  def format_requires_approval(entry)
    Event::Course::APPROVALS.map do |key|
      if entry.send("#{key}?")
        I18n.t("events.application_fields_pbs.#{key}")
      end
    end.compact.join(', ')
  end

  def format_camp_days(entry)
    if entry.camp_days.present?
      entry.camp_days.round(1)
    end
  end

  def show_camp_participation_status_dropdown?
    @event.is_a?(Event::Camp) &&
    entry.roles.any? { |r| Event::Camp.participant_types.any? { |t| r.is_a?(t) } } &&
    can?(:update, entry)
  end

  def expected_participants_value_present?(entry)
    attrs = [:expected_participants_wolf_f, :expected_participants_wolf_m,
             :expected_participants_pfadi_f, :expected_participants_pfadi_m,
             :expected_participants_pio_f, :expected_participants_pio_m,
             :expected_participants_rover_f, :expected_participants_pio_m,
             :expected_participants_leitung_f, :expected_participants_leitung_m
    ]
    attrs.any? { |a| entry.send(a).present? }
  end

end
