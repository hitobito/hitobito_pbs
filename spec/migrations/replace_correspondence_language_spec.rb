# frozen_string_literal: true

# Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
migration_file = Dir[Rails.root.join('../hitobito_pbs/db/migrate/20230915105810_replace_correspondance_language_with_core_language.rb')].first
require migration_file

describe ReplaceCorrespondanceLanguageWithCoreLanguage do
  let(:migration_context) { ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths).migrations }
  let(:previous_version) { 20230912120642 }
  let(:current_version) { 20230915105810 }
  subject(:migrate) { ActiveRecord::Migrator.new(:up, migration_context, current_version).migrate }
  around do |example|
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Migrator.new(:down, migrations, previous_version).migrate
      Person.reset_column_information
      example.run
      Person.reset_column_information
    end
  end

  subject(:migration) { described_class.new.tap { |migration| migration.verbose = false } }
  let(:kvs) do
    {
      be: Fabricate(Group::Kantonalverband.name, group: groups(:bund)),
      ju: Fabricate(Group::Kantonalverband.name, group: groups(:bund)),
      ti: Fabricate(Group::Kantonalverband.name, group: groups(:bund))
    }
  end
  let!(:kv_cantons) { kvs.map { |kv, group| KantonalverbandCanton.create!(kantonalverband: group, canton: kv) } }
  let!(:people) do
    {
      ti_nil: Fabricate(Group::Kantonalverband::Coach.name, group: kvs[:ti], correspondence_language: nil),
      ti_de: Fabricate(Group::Kantonalverband::Coach.name, group: kvs[:ti], correspondence_language: :de),
    }
  end

  describe '#up' do
    it '' do
      migrate
      people.values.each(&:reload)
      expect(people[:ti_nil].language).to eq(:it)
      expect(people[:ti_de].language).to eq(:de)
    end
  end
end
