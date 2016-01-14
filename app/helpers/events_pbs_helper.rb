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

  def format_event_j_s_kind(entry)
    if entry.j_s_kind.present?
      t("events.fields_pbs.j_s_kind_#{entry.j_s_kind}")
    else
      t('events.fields_pbs.j_s_kind_none')
    end
  end

  def format_event_js_security_attrs(entry)
    attrs = entry.used_attributes(:j_s_security_snow, :j_s_security_mountain, :j_s_security_water)
    human_names = attrs.select { |attr| entry.send(attr) }
                       .map { |attr| Event.human_attribute_name(attr) }.join(', ')
    human_names.present? ? human_names : t('events.fields_pbs.j_s_security_none')
  end

  def show_camp_participation_status_dropdown?
    @event.is_a?(Event::Camp) &&
    entry.roles.any? { |r| Event::Camp.participant_types.any? { |t| r.is_a?(t) } } &&
    can?(:update, entry)
  end

  def show_camp_cancel_own_button?
    if entry.is_a?(Event::Camp) && entry.cancel_possible?
      @user_participation = entry.participations.where(person_id: current_user.id).first
      @user_participation && can?(:cancel_own, @user_participation)
    else
      false
    end
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

  def camp_possible_canton_labels
    Cantons.labels.to_a.sort_by(&:last) +
      [[Event::Camp::ABROAD_CANTON, Cantons.full_name(Event::Camp::ABROAD_CANTON)]]
  end

  def camp_visiting_info(visiting, date)
    if visiting && date
      t('event/camp.visiting_info.at', date: f(date))
    else
      t("event/camp.visiting_info.#{visiting}")
    end
  end

  def format_event_canton(entry)
    Cantons.full_name(entry.canton.to_sym)
  end

  def save_camp_caption_text
    items = t('events.edit.save_camp_caption').split(/\n/)
    content_tag(:ul) do
      items.collect do |i|
        content_tag(:li, i)
      end.join.html_safe
    end
  end

  def format_event_abteilungsleitung_id(entry)
    advisor_link(entry.abteilungsleitung)
  end

  def format_event_coach_id(entry)
    advisor_link(entry.coach)
  end

  def format_event_advisor_mountain_security_id(entry)
    advisor_link(entry.advisor_mountain_security,
                 entry.j_s_security_mountain,
                 Event::Camp::Role::LeaderMountainSecurity)
  end

  def format_event_advisor_snow_security_id(entry)
    advisor_link(entry.advisor_snow_security,
                 entry.j_s_security_snow,
                 Event::Camp::Role::LeaderSnowSecurity)
  end

  def format_event_advisor_water_security_id(entry)
    advisor_link(entry.advisor_water_security,
                 entry.j_s_security_water,
                 Event::Camp::Role::LeaderWaterSecurity)
  end

  def advisor_link(advisor, required = true, required_leader = nil)
    content = []
    if required
      append_required_advisor(content, advisor)
      append_leader_warning(content, required_leader)
    else
      content << person_link(advisor)
    end
    content.join('<br/>'.html_safe).html_safe
  end

  def labeled_camp_days(event)
    label = t("activerecord.attributes.event.camp_days")
    labeled(label, event.camp_days)
  end

  private

  def append_required_advisor(content, advisor)
    if advisor
      content << person_link(advisor)
    else
      content << advisor_warning(:advisor_unassigned)
    end
  end

  def append_leader_warning(content, required_leader = nil)
    if required_leader && !camp_has_person_with_role(required_leader)
      content << advisor_warning(:leader_unassigned)
    end
  end

  def advisor_warning(key)
    content_tag(:span, class: 'label label-warning') do
      t("activerecord.attributes.event/camp.#{key.to_s}")
    end
  end

  def camp_has_person_with_role(role)
    role.joins(:event).where(event_participations: { event_id: entry.id }).exists?
  end

end
