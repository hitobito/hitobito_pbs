# encoding: utf-8
#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Pbs::Export::Tabular::People::HouseholdsFull do

  let(:leader) { people(:bulei) }
  let(:member) { people(:al_schekka) }
  let(:list) { Person.none }
  let(:exporter) { Pbs::Export::Tabular::People::HouseholdsFull.new(list) }

  context 'header' do
    it 'includes name, address attributes and layer group columns' do
      expect(exporter.attributes).to eq [:salutation, :name, :address, :zip_code, :town,
                                         :country, :layer_group, :correspondence_language,
                                         :prefers_digital_correspondence, :kantonalverband_id,
                                         :id, :layer_group_id, :company_name, :company]
    end
  end

  context 'data' do
    context 'of singular person' do
      let(:list) { Person.where(id: leader) }

      it 'is exported' do
        expect(exporter.data_rows.to_a).to eq [[
          "Sehr geehrter Herr Dr. Leiter",
          "Bundes Leiter",
          nil,
          nil,
          nil,
          nil,
          "Pfadibewegung Schweiz",
          nil,
          "nein",
          "CH",
          337180612,
          334539080,
          nil,
          "nein"
        ]]
      end
    end

    context 'of household' do
      let(:list) { Person.where(id: [leader, member]) }

      before do
        leader.update(household_key: '1234-1234-1234-1234',
                      prefers_digital_correspondence: true)
        member.update(household_key: leader.household_key,
                      address: leader.address,
                      zip_code: leader.zip_code,
                      town: leader.town,
                      prefers_digital_correspondence: leader.prefers_digital_correspondence)
      end

      it 'is exported' do
        expect(exporter.data_rows.to_a).to eq [[
          "Sehr geehrter Herr Dr. Leiter, sehr geehrte*r Schekka",
          "Bundes Leiter, AL Schekka",
          nil,
          nil,
          nil,
          nil,
          "Pfadibewegung Schweiz",
          nil,
          "ja",
          "CH",
          337180612,
          334539080,
          nil,
          "nein"
        ]]
      end
    end
  end

end
