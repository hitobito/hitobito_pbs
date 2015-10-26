# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplicationData

    # TODO test not tested methods

    attr_reader :camp, :camp_group

    delegate :t, :l, to: I18n

    EXPECTED_PARTICIPANT_KEYS = %w(wolf pfadi pio rover leitung)

    def initialize(camp)
      @camp = camp
      @camp_group = camp.groups.first
    end

    def expected_participant_table_header
      headers = ['']
      headers += EXPECTED_PARTICIPANT_KEYS.collect do |h|
        key = 'expected_participants_' + h
        t_camp_attr(key)
      end
    end

    def expected_participant_table_row(gender)
      row = [gender.to_s.upcase]
      row += EXPECTED_PARTICIPANT_KEYS.collect do |a|
        attr = "expected_participants_#{a}_#{gender.to_s}"
        @camp.send(attr.to_sym)
      end
    end

    def abteilung_name
      camp_abteilung ? camp_abteilung.to_s : camp_group.to_s
    end

    def camp_abteilung
      @camp_abteilung ||=
        camp_group.layer_hierarchy.detect {|g| g.is_a?(Group::Abteilung) }
    end

    def einheit_name
      unless camp_at_or_above_abteilung?
        camp_group.to_s
      end
    end

    def camp_attr_value(attr)
      value = @camp.send(attr)
      format_method = "format_#{attr.to_s}".to_sym
      if respond_to?(format_method, include_private: true)
        value = send(format_method, value)
      elsif boolean?(value)
        value = format_boolean(value)
      else
        value.to_s
      end
    end

    def active_qualifications(person)
      qualis = QualificationKind.joins(:qualifications).
        where(qualifications: { person_id: person.id }).
        merge(Qualification.active).
        uniq.
        list.
        collect(&:to_s).
        join("\n")
      qualis.present? ? qualis : text_no_entry
    end

    def t_camp_attr(key)
      text = t('activerecord.attributes.event.' + key)
      text = t('activerecord.attributes.event/camp.' + key) if text.match(/translation missing/)
      text
    end

    def camp_leader
      camp.participations_for(Event::Camp::Role::Leader).first.try(:person)
    end

    def camp_assistant_leaders
      camp.participations_for(Event::Camp::Role::AssistantLeader).collect(&:person)
    end

    def phone_number(person, label)
      person.phone_numbers.find_by(label: label).try(:number)
    end

    private

    def format_canton(value)
      Cantons.full_name(value.to_sym) if value.present?
    end

    def format_j_s_kind(value)
      if value.present?
        t("events.fields_pbs.j_s_kind_#{value}")
      else
        t('events.fields_pbs.j_s_kind_none')
      end
    end

    def format_state(value)
      t("activerecord.attributes.event/camp.states.#{value}")
    end

    def format_updated_at(value)
      date = format_date_time(value)
      person = @camp.updater.to_s
      "#{date} #{t('export/pdf/camp_application.by')} #{person}"
    end

    def format_coach_visiting(value)
      visiting_date = camp.coach_visiting_date
      format_visiting(value, visiting_date)
    end

    def format_al_visiting(value)
      visiting_date = camp.al_visiting_date
      format_visiting(value, visiting_date)
    end

    def format_visiting(value, visiting_date)
      formatted_value = format_boolean(value)
      if value && visiting_date.present? 
        formatted_value += ", #{format_date(visiting_date)}"
      end
      formatted_value
    end

    def format_date_time(value)
      l(value, format: :date_time)
    end

    def format_date(value)
      l(value, format: :default)
    end

    def format_boolean(value)
      value ? t('global.yes') : t('global.no')
    end

    def boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

    def text_no_entry
      t('global.associations.no_entry')
    end

    def camp_at_or_above_abteilung?
      camp_at_abteilung? || !camp_abteilung
    end

    def camp_at_abteilung?
      camp_group.is_a?(Group::Abteilung)
    end

  end
end
