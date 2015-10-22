# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Export::Pdf::CampApplicationData do

  describe 'section group' do
    context 'abteilung' do
      
      it 'returns Abteilung name if camp at Abteilung' do
        abteilung = groups(:patria)
        camp = Fabricate(:pbs_camp, groups: [abteilung])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.send(:abteilung_name)).to eq(abteilung.to_s)
      end
      
      it 'returns Abteilung name if camp below Abteilung' do
        pfadi = groups(:medusa)
        camp = Fabricate(:pbs_camp, groups: [pfadi])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.send(:abteilung_name)).to eq(groups(:schekka).to_s)
      end
      
      it 'returns Group name if camp above Abteilung' do
        bund = groups(:bund)
        camp = Fabricate(:pbs_camp, groups: [bund])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.send(:abteilung_name)).to eq(bund.to_s)
      end

    end

    context 'einheit' do

      it 'does not return Einheit name if camp at Abteilung' do
        abteilung = groups(:patria)
        camp = Fabricate(:pbs_camp, groups: [abteilung])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.send(:einheit_name)).to be_nil
      end
      
      it 'returns Einheit name if camp below Abteilung' do
        pfadi = groups(:medusa)
        camp = Fabricate(:pbs_camp, groups: [pfadi])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.send(:einheit_name)).to eq(pfadi.to_s)
      end

      it 'does not return Einheit name if camp above Abteilung' do
        bund = groups(:bund)
        camp = Fabricate(:pbs_camp, groups: [bund])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.send(:einheit_name)).to be_nil
      end

    end

    context 'expected participations table' do

      let(:camp) { Fabricate(:pbs_camp) }
      let(:data) { Export::Pdf::CampApplicationData.new(camp) }

      it 'has 6 header columns' do
        header_column = data.send(:expected_participant_table_header)
        expect(header_column).to eq ['', 'Wölfe', 'Pfadi', 'Pios', 'Rovers', 'Leiter']
      end

      it 'includes rows with expected participants count' do
        camp.update_attributes(
          expected_participants_wolf_f: 1,
          expected_participants_pfadi_f: 42,
          expected_participants_pio_f: 33,
          expected_participants_rover_f: 3,
          expected_participants_leitung_f: 99
        ) 

        row_f = data.send(:expected_participant_table_row, :f)
        expect(row_f).to eq ['F', 1, 42, 33, 3, 99]

        camp.update_attributes(
          expected_participants_wolf_m: 3,
          expected_participants_pfadi_m: 4,
          expected_participants_pio_m: 9,
          expected_participants_rover_m: 12,
          expected_participants_leitung_m: 9 
        ) 

        row_m = data.send(:expected_participant_table_row, :m)
        expect(row_m).to eq ['M', 3, 4, 9, 12, 9]
      end

    end

    context 'leader' do

      let(:camp) { Fabricate(:pbs_camp) }
      let(:leader) { Fabricate(:person) }
      let(:data) { Export::Pdf::CampApplicationData.new(camp) }

      it 'lists the leaders qualifications' do
        quali1 = Fabricate(:qualification, person: leader)
        quali2 = Fabricate(:qualification, person: leader)

        quali1_text = quali1.qualification_kind.to_s
        quali2_text = quali2.qualification_kind.to_s
        expect(data.send(:active_qualifications, leader)).to match quali1_text
        expect(data.send(:active_qualifications, leader)).to match /\n/
        expect(data.send(:active_qualifications, leader)).to match quali2_text
      end

    end

  end
end
