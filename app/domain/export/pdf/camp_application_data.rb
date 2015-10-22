# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplicationData
    
    attr_reader :camp, :camp_group

    delegate :t, :l, to: I18n

    EXPECTED_PARTICIPANT_KEYS = %w(wolf pfadi pio rover leitung)

    def initialize(camp)
      @camp = camp
      @camp_group = camp.groups.first
    end

    # participant table
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

    def camp_at_or_above_abteilung?
      camp_at_abteilung? || !camp_abteilung
    end

    def camp_at_abteilung?
      camp_group.is_a?(Group::Abteilung)
    end

    def camp_attr_value(attr)
      value = @camp.send(attr)
      if boolean?(value)
        value = t_boolean(value)
      elsif attr == :canton
        value = Cantons.full_name(value.to_sym)
      else
        value
      end
    end

    def active_qualifications(person)
      QualificationKind.joins(:qualifications).
                        where(qualifications: { person_id: person.id }).
                        merge(Qualification.active).
                        uniq.
                        list.
                        collect(&:to_s).
                        join("\n")
    end

    def t_camp_attr(key)
      t('activerecord.attributes.event.' + key)
    end

    def camp_leader
      camp.participations_for(Event::Camp::Role::Leader).first.try(:person)
    end

    def camp_assistant_leaders
      camp.participations_for(Event::Camp::Role::AssistantLeader).collect(&:person)
    end

    private

    def t_boolean(value)
      value ? t('global.yes') : t('global.no')
    end

    def boolean?(value)
      value.is_a?(TrueClass) || value.is_a?(FalseClass)
    end

  end
end
