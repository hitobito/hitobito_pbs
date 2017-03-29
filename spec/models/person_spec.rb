# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: people
#
#  id                      :integer          not null, primary key
#  first_name              :string(255)
#  last_name               :string(255)
#  company_name            :string(255)
#  nickname                :string(255)
#  company                 :boolean          default(FALSE), not null
#  email                   :string(255)
#  address                 :string(1024)
#  zip_code                :integer
#  town                    :string(255)
#  country                 :string(255)
#  gender                  :string(1)
#  birthday                :date
#  additional_information  :text
#  contact_data_visible    :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  encrypted_password      :string(255)
#  reset_password_token    :string(255)
#  reset_password_sent_at  :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0)
#  current_sign_in_at      :datetime
#  last_sign_in_at         :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_ip         :string(255)
#  picture                 :string(255)
#  last_label_format_id    :integer
#  creator_id              :integer
#  updater_id              :integer
#  primary_group_id        :integer
#  salutation              :string(255)
#  title                   :string(255)
#  grade_of_school         :integer
#  entry_date              :date
#  leaving_date            :date
#  j_s_number              :string(255)
#  correspondence_language :string(5)
#  brother_and_sisters     :boolean          default(FALSE), not null
#  failed_attempts         :integer          default(0)
#  locked_at               :datetime
#

require 'spec_helper'

describe Person do

  let(:person) { people(:bulei) }

  context 'validation' do
    it 'succeeds for available' do
      person.salutation = Salutation.available.keys.sample
      expect(person).to be_valid
    end

    it 'succeeds for empty' do
      person.salutation = ' '
      expect(person).to be_valid
    end

    it 'fails for non-available' do
      person.salutation = 'ahoi'
      expect(person).to have(1).error_on(:salutation)
    end
  end

  context '#salutation_value' do
    it 'is correct' do
      expect(person.salutation_value).to eq('Sehr geehrter Herr Dr. Leiter')
    end

    it 'is a default without salutation' do
      person.salutation = nil
      expect(person.salutation_value).to eq('Hallo Bundes')
    end
  end

  context '#salutation_label' do
    it 'is correct' do
      expect(person.salutation_label).to eq('Sehr geehrte(r) Frau/Herr [Titel] [Nachname]')
    end

    it 'is a default without salutation' do
      person.salutation = nil
      expect(person.salutation_label).to eq('Hallo [Name]')
    end
  end

  context '#pbs_number' do
    it 'handles short numbers' do
      person.id = 15
      expect(person.pbs_number).to eq('000-000-015')
    end

    it 'handles long numbers' do
      person.id = 123_456_789
      expect(person.pbs_number).to eq('123-456-789')
    end

    it 'handles very long numbers' do
      person.id = 1_234_567_891_234
      expect(person.pbs_number).to eq('1-234-567-891-234')
    end
  end

  context '#kantonalverband' do

    context 'unique' do
      before { person.reset_kantonalverband! }

      context 'bund' do
        it 'is CH' do
          expect(person.kantonalverband).to eq(groups(:bund))
        end
      end

      context 'in kantonalverband' do
        let(:person) { Fabricate(Group::Kantonalverband::Coach.name, group: groups(:be)).person }

        it 'is BE' do
          expect(person.kantonalverband).to eq(groups(:be))
        end
      end

      context 'in kantonalverband layer' do
        let(:person) { Fabricate(Group::KantonalesGremium::Mitglied.name, group: groups(:fg_football)).person }

        it 'is BE' do
          expect(person.kantonalverband).to eq(groups(:be))
        end

        it 'is BE even if primary group is nil' do
          person.update!(primary_group: nil)
          expect(person.kantonalverband).to eq(groups(:be))
        end
      end

      context 'in abteilung' do
        let(:person) { people(:al_schekka) }

        it 'is BE' do
          expect(person.kantonalverband).to eq(groups(:be))
        end
      end
    end

    context 'several' do
      context 'one bund, one kv' do

        it 'uses bund if primary group is there' do
          group = Fabricate(Group::BundesGremium.name, parent: groups(:bund))
          person = Fabricate(Group::BundesGremium::Leitung.name, group: group).person
          Fabricate(Group::Kantonalverband::Coach.name, group: groups(:zh), person: person)

          person.reload
          person.reset_kantonalverband!

          expect(person.kantonalverband).to eq(groups(:bund))
        end

        it 'changes kantonalverband if primary group changes' do
          group = Fabricate(Group::BundesGremium.name, parent: groups(:bund))
          person = Fabricate(Group::BundesGremium::Leitung.name, group: group).person
          Fabricate(Group::Kantonalverband::Coach.name, group: groups(:zh), person: person)

          person.reload
          person.update!(primary_group: groups(:zh))

          expect(person.reload.kantonalverband).to eq(groups(:zh))
        end

      end

      context 'two kv' do

        it 'uses primary group' do
          person = Fabricate(Group::Kantonalverband::Coach.name, group: groups(:be)).person
          Fabricate(Group::Kantonalverband::Coach.name, group: groups(:zh), person: person)

          person.reload
          person.reset_kantonalverband!

          expect(person.kantonalverband).to eq(groups(:be))
        end

        it 'is nil if primary group is nil' do
          person = Fabricate(Group::Kantonalverband::Coach.name, group: groups(:be)).person
          Fabricate(Group::Kantonalverband::Coach.name, group: groups(:zh), person: person)

          person.update!(primary_group: nil)

          expect(person.kantonalverband).to be_nil
        end

        it 'changes kantonalverband if primary group changes' do
          group = Fabricate(Group::BundesGremium.name, parent: groups(:bund))
          person = Fabricate(Group::BundesGremium::Leitung.name, group: group).person
          Fabricate(Group::Kantonalverband::Coach.name, group: groups(:be), person: person)
          Fabricate(Group::Kantonalverband::Coach.name, group: groups(:zh), person: person)

          person.reload
          person.update!(primary_group: groups(:zh))

          expect(person.reload.kantonalverband).to eq(groups(:zh))
        end

      end

    end
  end
end
