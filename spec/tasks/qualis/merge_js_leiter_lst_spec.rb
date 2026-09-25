# frozen_string_literal: true

#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"
require HitobitoPbs::Wagon.root.join("lib/tasks/qualis/merge_js_leiter_lst")

describe Qualis::MergeJsLeiterLst do
  let(:kinder) { Fabricate(:qualification_kind, label: "J+S Leiter*in LS/T Kinder", validity: 2) }
  let(:jugendliche) do
    Fabricate(:qualification_kind, label: "J+S Leiter*in LS/T Jugendliche", validity: 2)
  end
  let(:target) { Fabricate(:qualification_kind, label: "J+S Leiter*in LS/T", validity: 2) }
  let(:person) { people(:bulei) }
  let(:cutoff) { Date.new(2026, 12, 31) }

  subject(:task) do
    described_class.new(target_kind_id: target.id,
      source_kind_ids: [kinder.id, jugendliche.id],
      dry_run: dry_run)
  end

  let(:dry_run) { false }

  it "converts a still valid qualification, preserving expiry, origin and qualified_at" do
    old = create_quali(kinder, start_at: Date.new(2024, 3, 15), finish_at: Date.new(2028, 12, 31),
      origin: "Basiskurs Wolfsstufe 2024", qualified_at: Date.new(2024, 3, 22))

    expect { task.run }.to change { target_qualifications.count }.by(1)

    quali = target_qualifications.first
    expect(quali.start_at).to eq(Date.new(2027, 1, 1))
    expect(quali.finish_at).to eq(Date.new(2028, 12, 31))
    expect(quali.origin).to eq("Basiskurs Wolfsstufe 2024")
    expect(quali.qualified_at).to eq(Date.new(2024, 3, 22))
    expect(old.reload.finish_at).to eq(cutoff)
  end

  it "preserves unlimited validity" do
    old = create_quali(kinder, finish_at: nil)

    task.run

    expect(target_qualifications.first.finish_at).to be_nil
    expect(old.reload.finish_at).to eq(cutoff)
  end

  it "carries over the event participation" do
    participation = event_participations(:top_leader)
    create_quali(kinder, event_participation: participation)

    task.run

    expect(target_qualifications.first.event_participation).to eq(participation)
  end

  it "ignores qualifications that already expire before the cutoff" do
    old = create_quali(kinder, finish_at: Date.new(2025, 12, 31))

    expect { task.run }.not_to change { Qualification.count }
    expect(old.reload.finish_at).to eq(Date.new(2025, 12, 31))
  end

  it "ignores qualifications starting after the cutoff" do
    create_quali(kinder, start_at: Date.new(2027, 3, 1), finish_at: Date.new(2029, 12, 31))

    expect { task.run }.not_to change { Qualification.count }
  end

  it "ignores other qualification kinds" do
    other = Fabricate(:qualification_kind, label: "Irgendwas", validity: 2)
    old = create_quali(other, finish_at: Date.new(2028, 12, 31))

    expect { task.run }.not_to change { Qualification.count }
    expect(old.reload.finish_at).to eq(Date.new(2028, 12, 31))
  end

  context "holding both source kinds" do
    it "creates a single qualification with the latest expiry and its origin" do
      early = create_quali(kinder, finish_at: Date.new(2027, 12, 31), origin: "Wolfsstufe")
      late = create_quali(jugendliche, finish_at: Date.new(2028, 12, 31), origin: "Pfadistufe")

      expect { task.run }.to change { target_qualifications.count }.by(1)

      quali = target_qualifications.first
      expect(quali.finish_at).to eq(Date.new(2028, 12, 31))
      expect(quali.origin).to eq("Pfadistufe")
      expect(early.reload.finish_at).to eq(cutoff)
      expect(late.reload.finish_at).to eq(cutoff)
    end

    it "prefers the unlimited qualification" do
      create_quali(kinder, finish_at: Date.new(2028, 12, 31), origin: "Wolfsstufe")
      create_quali(jugendliche, finish_at: nil, origin: "Pfadistufe")

      task.run

      quali = target_qualifications.first
      expect(quali.finish_at).to be_nil
      expect(quali.origin).to eq("Pfadistufe")
    end
  end

  it "logs how many qualifications it creates and ends, not how many it looked at" do
    create_quali(kinder, finish_at: Date.new(2027, 12, 31))
    create_quali(jugendliche, finish_at: cutoff)

    expect { task.run }.to output(/Creating 1 .* from 2 still valid .*Ending 1 /m).to_stdout
  end

  it "does not count qualifications already ending on the cutoff as ended" do
    create_quali(kinder, finish_at: cutoff)

    expect { task.run }.to output(/Ending 0 /).to_stdout
    expect(target_qualifications.count).to eq(1)
  end

  it "can be run twice without creating a second qualification" do
    create_quali(kinder, finish_at: Date.new(2028, 12, 31))
    task.run

    expect { task.run }.not_to change { Qualification.count }
    expect(target_qualifications.first.finish_at).to eq(Date.new(2028, 12, 31))
  end

  context "dry run" do
    let(:dry_run) { true }

    it "writes nothing" do
      old = create_quali(kinder, finish_at: Date.new(2028, 12, 31))

      expect { task.run }.not_to change { Qualification.count }
      expect(old.reload.finish_at).to eq(Date.new(2028, 12, 31))
    end
  end

  private

  def target_qualifications
    person.qualifications.where(qualification_kind: target)
  end

  def create_quali(kind, start_at: Date.new(2024, 3, 15), finish_at: Date.new(2028, 12, 31),
    **attrs)
    Fabricate(:qualification, person: person, qualification_kind: kind, start_at: start_at,
      **attrs).tap { |quali| quali.update_column(:finish_at, finish_at) }
  end
end
