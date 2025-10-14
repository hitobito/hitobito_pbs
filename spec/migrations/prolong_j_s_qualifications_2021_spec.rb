# frozen_string_literal: true

# Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

require "spec_helper"
migration_file_name = Dir[
  Rails.root.join("..", "hitobito_pbs", "db", "migrate",
    "20211109094956_prolong_j_s_qualifications_2021.rb"),
  Rails.root.join("hitobito_pbs", "db", "migrate",
    "20211109094956_prolong_j_s_qualifications_2021.rb")
].first
require migration_file_name

describe ProlongJSQualifications2021 do
  let(:migration) { described_class.new.tap { |m| m.verbose = false } }

  let!(:qk_js_leiter) do
    QualificationKind.create!(label: "J+S Leiter*in LS/T Kindersport", validity: 2)
  end

  let!(:ek_qk_js_leiter) do
    Event::KindQualificationKind.create!(qualification_kind: qk_js_leiter,
      event_kind: event_kinds(:lpk),
      category: "qualification",
      role: "participant")
  end

  let!(:qk_js_coach) do
    QualificationKind.create!(label: "J+S Coach", validity: 2)
  end

  let!(:ek_qk_js_coach) do
    Event::KindQualificationKind.create!(qualification_kind: qk_js_coach,
      event_kind: event_kinds(:lpk),
      category: "qualification",
      role: "participant")
  end

  let!(:event_kind_js) {
    Event::Kind.create!(label: "JS",
      event_kind_qualification_kinds: [ek_qk_js_leiter, ek_qk_js_coach])
  }

  let!(:js_course_2021) { create_js_course(2021) }
  let!(:js_course_2020) { create_js_course(2020) }
  let!(:js_course_2019) { create_js_course(2019) }
  let!(:js_course_2018) { create_js_course(2018) }

  let(:extension_date) { Date.new(2022, 12, 31) }

  context "#up" do
    it "prolongs specific js qualifications completed in 2019" do
      migration.up

      js_course_2018.participations.each do |p|
        expect(p.person.qualifications.first.finish_at).not_to eq(extension_date)
      end

      js_course_2019.participations.each do |p|
        # should be prolonged (leiter)
        expect(qualifications(p.person, qk_js_leiter).first.finish_at).to eq(extension_date)

        # should not be changed (coach)
        expect(qualifications(p.person, qk_js_coach).first.finish_at).not_to eq(extension_date)
      end

      js_course_2020.participations.each do |p|
        # was already set to 2022-12-31 when issued
        expect(p.person.qualifications.first.finish_at).to eq(extension_date)
      end

      js_course_2021.participations.each do |p|
        expect(p.person.qualifications.first.finish_at).not_to eq(extension_date)
      end
    end
  end

  private

  def qualifications(person, qualification_kind)
    person.qualifications.where(qualification_kind_id: qualification_kind)
  end

  def create_js_course(year)
    course = Fabricate(:course, kind: event_kind_js, dates: event_dates(year))
    12.times do
      # rubocop:todo Layout/LineLength
      participation = Fabricate(:pbs_participation, event: course, qualified: true, state: :assigned,
        # rubocop:enable Layout/LineLength
        roles: [Event::Course::Role::Participant.new])
      Event::Qualifier.for(participation).issue
    end
    course
  end

  def event_dates(year)
    start_at = Date.new(year, 0o6, 11)
    [Fabricate(:event_date, start_at: start_at, finish_at: start_at + 8.days)]
  end
end
