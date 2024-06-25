#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_jubla and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_jubla.

module Pbs::Export::Tabular::Events
  module BsvRow
    extend ActiveSupport::Concern

    included do
      alias_method :language_count, :language_count_pbs

      class_attribute :all_participant_roles
      self.all_participant_roles = Event::Course.role_types.flatten - [Event::Course::Role::Advisor]

      delegate :id, :first_name, :last_name, :nickname,
        :address, :zip_code, :town, :country, :email, :salutation_value, to: :advisor

      remove_method :training_days
    end

    def last_event_date
      event_date = entry.dates.reorder(:finish_at).last
      end_date = event_date.finish_at || event_date.start_at
      end_date.strftime("%d.%m.%Y")
    end

    def training_days
      Kernel.format("%g", entry.training_days) if entry.training_days
    end

    def bsv_days
      Kernel.format("%g", entry.bsv_days) if entry.bsv_days
    end

    def kurs_kind
      entry.kind.to_s
    end

    def kantonalverband
      entry.groups.where(type: "Group::Kantonalverband").join(", ") || nil
    end

    def region
      entry.groups.where(type: "Group::Region").join(", ") || nil
    end

    def language_count_pbs
      langs = [:language_de, :language_fr, :language_it, :language_en]
      count = 0
      langs.each { |l| count += 1 if entry.send(l) }
      count
    end

    def advisor
      @advisor ||= Person.new(entry.advisor ? entry.advisor.attributes.except("picture") : {})
    end

    def bsv_eligible_participations_count
      bsv_eligible_participations.count
    end

    def all_participants_count
      all_participants.count
    end

    def all_participants_attendances
      active_participations.map(&:bsv_days).compact.sum
    end

    def bsv_eligible_attendances
      bsv_eligible_participations.map(&:bsv_days).compact.sum
    end

    def all_participants_attendance_summary
      format_attendances(attendance_groups_by_bsv_days_for(active_participations))
    end

    def bsv_eligible_attendance_summary
      format_attendances(attendance_groups_by_bsv_days_for(bsv_eligible_participations))
    end

    private

    def participations_for(role_types)
      info.send(:participations_for, role_types)
    end

    def bsv_eligible_participations
      @bsv_eligible_participations ||= active_participations.select do |participation|
        person = participation.person
        person.birthday? &&
          info.send(:aged_under_30?, person) &&
          info.send(:ch_resident?, person)
      end
    end

    def all_participants
      @all_participants ||= participations_for(all_participant_roles).collect { |p| p.person }
    end

    def active_participations
      @active_participations ||= entry.participations.where(active: true).select { |p|
        exclude_advisor(p)
      }
    end

    def exclude_advisor(participation)
      !(participation.roles.one? && participation.roles.first.instance_of?(Event::Course::Role::Advisor))
    end

    def attendance_groups_by_bsv_days_for(participations)
      participations
        .group_by { |participation| participation.bsv_days || 0 }
        .transform_values { |participation_group| participation_group.count }
        .sort_by { |days, count| days.to_f }.to_h
    end

    def format_attendances(attendance_groups)
      return nil if attendance_groups.none?

      attendance_groups.collect { |days, count| "#{count}x#{sprintf("%g", days)}" }.join(", ")
    end
  end
end
