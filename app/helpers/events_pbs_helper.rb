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

  def format_event_j_s_kind(entry)
    if entry.j_s_kind.present?
      t("events.fields_pbs.j_s_kind_#{entry.j_s_kind}")
    else
      t('events.fields_pbs.j_s_kind_none')
    end
  end

  def show_camp_participation_status_dropdown?
    @event.is_a?(Event::Camp) &&
    entry.roles.any? { |r| Event::Camp.participant_types.any? { |t| r.is_a?(t) } } &&
    can?(:update, entry)
  end

  def expected_participants_value_present?(entry)
    Event::Camp::EXPECTED_PARTICIPANT_ATTRS.any? { |a| entry.send(a).present? }
  end

  def camp_list_permitting_kantonalverbaende
    roles = current_user.roles.select do |role|
      EventAbility::CANTONAL_CAMP_LIST_ROLES.any? { |t| role.is_a?(t) }
    end
    roles.collect(&:group).uniq.sort_by(&:to_s)
  end

  def camp_list_permitted_cantons
    camp_list_permitting_kantonalverbaende.
      collect(&:cantons).
      flatten.
      uniq.
      collect { |c| [c, Cantons.full_name(c)] }.
      sort_by(&:last)
  end

  def camp_possible_canton_values
    Event::Camp.possible_canton_values.
      collect do |c|
        # TODO add abroad locale key
        label = (c == Event::Camp::ABROAD_CANTON) ? t('Abroad') : c.upcase
        [c, label]
      end
  end

end
