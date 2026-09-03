# frozen_string_literal: true

#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Qualis
  # Merges the J+S Leiter*in LS/T Kinder and Jugendliche qualifications into the single
  # J+S Leiter*in LS/T qualification (pbs#482): qualifications still valid on the cutoff
  # date end on it, and the new one starts the day after, keeping expiry, origin and
  # participation.
  class MergeJsLeiterLst
    CUTOFF = Date.new(2026, 12, 31)
    STARTS_AT = CUTOFF + 1.day

    def initialize(target_kind_id:, source_kind_ids:, dry_run: false)
      @target_kind = QualificationKind.find(target_kind_id)
      @source_kinds = QualificationKind.where(id: source_kind_ids).to_a
      if @source_kinds.size != source_kind_ids.size
        raise ActiveRecord::RecordNotFound, "unknown source qualification kinds"
      end

      @dry_run = dry_run
    end

    def run
      Qualification.transaction do
        say("Dry run, all changes will be rolled back") if @dry_run
        still_valid = still_valid_sources
        created = convert(still_valid)
        ended = end_on_cutoff(still_valid)
        say("Created #{created} #{@target_kind.label} qualifications, " \
            "ended #{ended} #{source_labels} on #{CUTOFF}")
        raise ActiveRecord::Rollback if @dry_run
      end
    end

    private

    def source_labels
      @source_kinds.map(&:label).join(" / ")
    end

    def still_valid_sources
      Qualification
        .where(qualification_kind_id: @source_kinds.map(&:id))
        .active(CUTOFF)
        .to_a
    end

    def convert(still_valid)
      sources = per_person(still_valid)
      say_with_time("Creating #{sources.size} #{@target_kind.label} qualifications from " \
                    "#{still_valid.size} still valid #{source_labels}") do
        sources.each_value { |source| create(source) }
        sources.size
      end
    end

    # One qualification per person, as the two kinds become a single one. People that
    # already hold the target are skipped.
    def per_person(still_valid)
      people_with_target = Qualification
        .where(qualification_kind_id: @target_kind.id).pluck(:person_id).to_set
      still_valid
        .reject { |quali| people_with_target.include?(quali.person_id) }
        .group_by(&:person_id)
        .transform_values { |qualis| latest(qualis) }
    end

    def latest(qualis)
      qualis.find { |quali| quali.finish_at.nil? } || qualis.max_by(&:finish_at)
    end

    # finish_at is written separately because Qualification#set_finish_at recomputes it
    # from the kind's validity on every save, which would discard the preserved expiry.
    def create(source)
      Qualification.create!(person_id: source.person_id,
        qualification_kind: @target_kind,
        start_at: STARTS_AT,
        qualified_at: source.qualified_at,
        origin: source.origin,
        event_participation_id: source.event_participation_id)
        .update_column(:finish_at, source.finish_at)
    end

    def end_on_cutoff(still_valid)
      too_late = still_valid.select { |quali| quali.finish_at.nil? || quali.finish_at > CUTOFF }
      say_with_time("Ending #{too_late.size} #{source_labels} on #{CUTOFF}") do
        Qualification.where(id: too_late.map(&:id)).update_all(finish_at: CUTOFF)
      end
    end

    def say_with_time(message)
      say(message)
      result = nil
      elapsed = ActiveSupport::Benchmark.realtime { result = yield }
      say("%.4fs" % elapsed, true)
      say("#{result} rows", true) if result.is_a?(Integer)
      result
    end

    def say(message, subitem = false)
      puts "#{subitem ? "   ->" : "--"} #{message}" # rubocop:disable Rails/Output
    end
  end
end
