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

        expect(data.abteilung_name).to eq(abteilung.to_s)
      end
      
      it 'returns Abteilung name if camp below Abteilung' do
        pfadi = groups(:medusa)
        camp = Fabricate(:pbs_camp, groups: [pfadi])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.abteilung_name).to eq(groups(:schekka).to_s)
      end
      
      it 'returns Group name if camp above Abteilung' do
        bund = groups(:bund)
        camp = Fabricate(:pbs_camp, groups: [bund])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.abteilung_name).to eq(bund.to_s)
      end

    end

    context 'einheit' do

      it 'does not return Einheit name if camp at Abteilung' do
        abteilung = groups(:patria)
        camp = Fabricate(:pbs_camp, groups: [abteilung])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.einheit_name).to be_nil
      end
      
      it 'returns Einheit name if camp below Abteilung' do
        pfadi = groups(:medusa)
        camp = Fabricate(:pbs_camp, groups: [pfadi])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.einheit_name).to eq(pfadi.to_s)
      end

      it 'does not return Einheit name if camp above Abteilung' do
        bund = groups(:bund)
        camp = Fabricate(:pbs_camp, groups: [bund])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.einheit_name).to be_nil
      end

    end

    context 'kantonalverband' do
      it 'does not return Kantonalverband if camp at Bund' do
        bund = groups(:bund)
        camp = Fabricate(:pbs_camp, groups: [bund])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.kantonalverband).to be_nil
      end
      
      it 'returns Kantonalverband if camp at Kantonalverband' do
        canton = groups(:be)
        camp = Fabricate(:pbs_camp, groups: [canton])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.kantonalverband).to eq(canton)
      end

      it 'returns Kantonalverband if camp below Kantonalverband' do
        kyburg = groups(:kyburg)
        camp = Fabricate(:pbs_camp, groups: [kyburg])
        data = Export::Pdf::CampApplicationData.new(camp)

        expect(data.kantonalverband).to eq(groups(:be))
      end
    end

    context 'expected participations table' do

      let(:camp) { Fabricate(:pbs_camp) }
      let(:data) { Export::Pdf::CampApplicationData.new(camp) }

      it 'has 6 header columns' do
        header_column = data.expected_participant_table_header
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

        row_f = data.expected_participant_table_row(:f)
        expect(row_f).to eq ['F', 1, 42, 33, 3, 99]

        camp.update_attributes(
          expected_participants_wolf_m: 3,
          expected_participants_pfadi_m: 4,
          expected_participants_pio_m: 9,
          expected_participants_rover_m: 12,
          expected_participants_leitung_m: 9 
        ) 

        row_m = data.expected_participant_table_row(:m)
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
        expect(data.active_qualifications(leader)).to match quali1_text
        expect(data.active_qualifications(leader)).to match /\n/
        expect(data.active_qualifications(leader)).to match quali2_text
      end

      it 'returns none if leader has no qualifications' do
        expect(data.active_qualifications(leader)).to match(/keine/)
      end

    end

    context 'camp attribute value formatting' do
      let(:coach) { Fabricate(:person) }
      let(:camp) { Fabricate(:pbs_camp, coach_id: coach.id) }
      let(:data) { Export::Pdf::CampApplicationData.new(camp) }

      context 'coach' do
        it 'prints no if coach not visiting' do
          camp.update_attribute(:coach_visiting_date, Date.parse('15.07.1982'))
          camp.update_attribute(:coach_visiting, false)
          expect(data.camp_attr_value(:coach_visiting)).to eq 'nein'
        end
        it 'prints yes with date if coach visiting' do
          camp.update_attribute(:coach_visiting_date, Date.parse('15.07.1982'))
          camp.update_attribute(:coach_visiting, true)
          expect(data.camp_attr_value(:coach_visiting)).to eq 'ja, 15.07.1982'
        end
        it 'prints yes without date if coach visiting' do
          camp.update_attribute(:coach_visiting, true)
          expect(data.camp_attr_value(:coach_visiting)).to eq 'ja'
        end
      end

      context 'abteilungsleitung' do
        it 'prints no if al not visiting' do
          camp.update_attribute(:al_visiting_date, Date.parse('15.07.2000'))
          camp.update_attribute(:al_visiting, false)
          expect(data.camp_attr_value(:al_visiting)).to eq 'nein'
        end
        it 'prints yes with date if al visiting' do
          camp.update_attribute(:al_visiting_date, Date.parse('15.07.2000'))
          camp.update_attribute(:al_visiting, true)
          expect(data.camp_attr_value(:al_visiting)).to eq 'ja, 15.07.2000'
        end
        it 'prints yes without date if al visiting' do
          camp.update_attribute(:al_visiting, true)
          expect(data.camp_attr_value(:al_visiting)).to eq 'ja'
        end
      end

      context 'canton' do
        it 'prints full canton name' do
          camp.update_attribute(:canton, 'be')
          expect(data.camp_attr_value(:canton)).to eq 'Bern'
        end
        it 'prints ausland' do
          camp.update_attribute(:canton, 'zz')
          expect(data.camp_attr_value(:canton)).to eq 'Ausland'
        end
      end

      context 'j+s kind' do
        it 'prints j+s kind' do
          camp.update_attribute(:j_s_kind, 'j_s_child')
          expect(data.camp_attr_value(:j_s_kind)).to eq 'J+S Kindersport'
        end
      end

      context 'camp state' do
        it 'prints camp state' do
          camp.update_attribute(:state, 'canceled')
          expect(data.camp_attr_value(:state)).to eq 'Abgesagt'
        end
      end

      context 'format person' do
        it 'prints name and nick' do
          advisor_water = Fabricate(:person)
          camp.update_attribute(:advisor_water_security_id, advisor_water.id)
          expect(data.camp_attr_value(:advisor_water_security)).to eq advisor_water.to_s
        end
      end

      context 'format j+s security' do
        it 'prints none' do
          expect(data.js_security_value).to eq '(keiner)'
        end

        it 'prints snow and water' do
          camp.update_attribute(:j_s_security_snow, true)
          camp.update_attribute(:j_s_security_mountain, true)
          expect(data.js_security_value).to eq 'Winter, Berg'
        end
      end

    end

  end
end
