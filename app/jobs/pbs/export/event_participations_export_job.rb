#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::Export::EventParticipationsExportJob
  def exporter
    if @options[:household_details]
      return Pbs::Export::Tabular::People::ParticipationsHouseholdsFull
    end
    super
  end

  def entries # rubocop:todo Metrics/CyclomaticComplexity
    filtered = super
    if @options[:nds_course] && ability.can?(:show_details, filtered.first)
      unfiltered_participants
    elsif @options[:nds_camp] && ability.can?(:show_details, filtered.first)
      unfiltered_participants
    elsif @options[:slrg] && ability.can?(:show_details, filtered.first)
      unfiltered_participants
    else
      super
    end
  end

  def unfiltered_participants
    ::Event::ParticipationFilter.new(event, user, filter: "participants").list_entries
  end

  def data
    return super unless exporter == ::Export::Tabular::People::ParticipationsFull
    ::Export::Tabular::People::ParticipationsFull.export(@format, entries, event)
  end
end
