# frozen_string_literal: true

# Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

require "spec_helper"
migration_file_name = Dir[
  Rails.root.join("..", "hitobito_pbs", "db", "migrate",
    "20230915105810_replace_correspondence_language_with_core_language.rb"),
  Rails.root.join("hitobito_pbs", "db", "migrate",
    "20230915105810_replace_correspondence_language_with_core_language.rb")
].first
require migration_file_name

describe ReplaceCorrespondenceLanguageWithCoreLanguage do
  subject(:migration) { described_class.new.tap { |migration| migration.verbose = false } }

  describe "#infer_person_language" do
    let(:person) { Fabricate(:person) }
    let(:language) { nil }
    let(:correspondence_language) { nil }

    subject(:infer_person_language) { migration.infer_person_language(person) }

    before do
      allow(person).to receive(:language).and_return(language)
      allow(person).to receive(:correspondence_language).and_return(correspondence_language)
    end

    context "with existing language" do
      let(:language) { :test }

      it { expect(infer_person_language).to eq(language) }
    end

    context "with existing correspondance_language" do
      let(:correspondence_language) { :test }

      it { expect(infer_person_language).to eq(:test) }
    end

    context "with language from KV" do
      let(:person) { Fabricate(Group::Kantonalverband::Coach.name, group: kv).person }
      let(:kv) do
        Fabricate(Group::Kantonalverband.name, parent: groups(:bund)).tap do |kv|
          kv.kantonalverband_cantons.create!(canton: canton)
        end
      end

      context "with KV ti" do
        let(:canton) { :ti }

        it { expect(infer_person_language).to eq(:it) }
      end

      context "with KV ju" do
        let(:canton) { :ju }

        it { expect(infer_person_language).to eq(:fr) }
      end

      context "with KV be" do
        let(:canton) { :be }

        it { expect(infer_person_language).to eq(:de) }
      end
    end
  end
end
