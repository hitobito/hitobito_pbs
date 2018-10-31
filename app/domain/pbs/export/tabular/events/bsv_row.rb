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

      delegate :id, :first_name, :last_name, :nickname,
               :address, :zip_code, :town, :country, :email, :salutation_value, to: :advisor
    end

    def last_event_date
      event_date = entry.dates.reorder(:finish_at).last
      end_date = event_date.finish_at || event_date.start_at
      end_date.strftime('%d.%m.%Y')
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

  end
end
