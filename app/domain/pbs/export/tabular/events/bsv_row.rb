# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
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
      end_date.strftime('%d.%m.%Y')
    end

    def training_days
      Kernel.format('%g', entry.training_days) if entry.training_days
    end

    def bsv_days
      Kernel.format('%g', entry.bsv_days) if entry.bsv_days
    end

    def kurs_kind
      entry.kind.to_s
    end

    def kantonalverband
      entry.groups.where(type: Group::Kantonalverband).join(', ') || nil
    end

    def region
      entry.groups.where(type: Group::Region).join(', ') || nil
    end

    def language_count_pbs
      langs = [:language_de, :language_fr, :language_it, :language_en]
      count = 0
      langs.each { |l| count += 1 if entry.send(l) }
      count
    end

    def advisor
      @advisor ||= Person.new(entry.advisor ? entry.advisor.attributes : {})
    end

    def eligible_attendance_summary
      format_attendances(bsv_eligible_participants(all_participants))
    end

    def eligible_count
      bsv_eligible_participants(all_participants).count
    end

    def all_participants_count
      all_participants.count
    end

    def all_participants_attendance_summary
      format_attendances(all_participants)
    end

    def all_eligible_attendance_summary
      format_attendances(bsv_eligible_participants(all_participants))
    end

    private

    def participations_for(role_types)
      @info.send(:participations_for, role_types)
    end

    def bsv_eligible_participants(participations)
      participations.
        collect(&:person).
        select do |person|
          person.birthday? &&
          @info.send(:aged_17_to_30?, person) &&
          @info.send(:ch_resident?, person)
        end
    end

    def all_participants
      @all_participants ||= participations_for(all_participant_roles).collect { |p| p.person }
    end

    def active_participations
      @active_participations ||= entry.participations.where(active: true)
    end

    def attendances_grouped_by_bsv_days_for(participants)
      active_participations.
        select { |participation| participants.include?(participation.person) }.
        group_by { |participation| participation.bsv_days }.
        transform_values { |participations| participations.count }.
        sort_by { |days, count| days.to_f }.to_h
    end

    def format_attendances(participants)
      attendances_grouped_by_bsv_days_for(participants).collect do |counts|
        "#{counts[1]}x#{sprintf('%g',counts[0])}"
      end.join(', ').to_s
    end
  end
end
