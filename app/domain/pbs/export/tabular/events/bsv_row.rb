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

    def attendance_summary
      format_attendances(attendances_grouped_by_bsv_days_for(@info.participants_aged_17_to_30))
    end

    def all_participants_count
      participations_for(all_participant_roles).count
    end

    def all_participants_attendance_summary
      format_attendances(attendances_grouped_by_bsv_days_for(all_participants))
    end

    private

    def participations_for(role_types)
      active_participations.select { |p| contains_any?(role_types, p.roles.collect(&:class)) }
    end

    def all_participants
      participations_for(all_participant_roles).collect { |p| p.person }
    end

    def active_participations
      entry.participations.where(active: true)
    end

    def attendances_grouped_by_bsv_days_for(participants)
      active_participations.inject({}) do |attendances, p|
        if participants.include? (p.person)
          bsv_days = p.bsv_days || 0
          attendances[bsv_days] ? attendances[bsv_days] += 1 : attendances[bsv_days] = 1
        end
        attendances
      end
    end

    def format_attendances(attendances)
      sorted_attendances = attendances.sort_by { |days, count| days.to_f }.to_h
      sorted_attendances.inject([]) do |formatted_counts, counts|
        formatted_counts << "#{counts[1]}x#{sprintf('%g',counts[0])}"
      end.join(', ').to_s
    end

    def contains_any?(required, existing)
      (required & existing).present?
    end
  end
end
