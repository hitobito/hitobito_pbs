# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Course do

  subject do
    Fabricate(:course, kind: event_kinds(:fut))
  end

  before { is_expected.to be_valid }

  context 'advisor' do

    it 'is an alias for coach' do
      subject.coach_id = people(:bulei).id

      expect(subject.advisor_id).to eq(people(:bulei).id)
      subject.save!
      expect(subject.advisor).to eq(people(:bulei))
    end

    it 'is not in role types' do
      expect(subject.role_types).not_to include(Event::Course::Role::Advisor)
    end

    it 'has coach in role types instead' do
      expect(subject.role_types).to include(Event::Camp::Role::Coach)
    end

    it 'is not in used attributes' do
      expect(subject.used_attributes).not_to include(:advisor_id)
    end

    it 'has coach_id in used attributes instead' do
      expect(subject.used_attributes).to include(:coach_id)
    end

  end

  context 'expected_participants' do
    it 'does not accept negative values' do
      subject.expected_participants_rover_f = -33
      is_expected.not_to be_valid
    end

    it 'does not accept non integer values' do
      subject.expected_participants_pio_m = 33.3
      is_expected.not_to be_valid
    end

    it 'accepts any positive integer' do
      subject.expected_participants_pio_m = 42
      is_expected.to be_valid
    end
  end

  context '#j_s_kind' do
    it 'accepts empty value' do
      subject.j_s_kind = nil
      is_expected.to be_valid

      subject.j_s_kind = ''
      is_expected.to be_valid
    end

    %w(j_s_child j_s_youth j_s_mixed).each do |kind|
      it "accepts '#{kind}'" do
        subject.j_s_kind = kind
        is_expected.to be_valid
      end
    end

    it 'does not accept any other string' do
      subject.j_s_kind = 'asdf'
      is_expected.not_to be_valid
    end
  end

  context 'reset coach confirmed' do
    it 'sets to false if changed' do
      subject.update!(coach_id: people(:bulei).id)
      subject.update!(coach_confirmed: true)

      subject.update!(coach_id: people(:al_berchtold).id)
      expect(subject.coach_confirmed).to eq false
    end

    it 'keeps if unchanged' do
      subject.update!(coach_id: people(:bulei).id)
      subject.update!(coach_confirmed: true)

      subject.update!(altitude: 22)
      expect(subject.coach_confirmed).to eq true
    end
  end

  context 'camp days' do
    it 'counts dates without finish at as one day' do
      subject.dates.first.update!(finish_at: nil)
      expect(subject.camp_days).to eq 1
    end

    it 'counts number of dates given by event date' do
      date = subject.dates.first
      finish_at = date.start_at + 5.days
      date.update!(finish_at: finish_at)
      expect(subject.camp_days).to eq 6
    end

    it 'accumulates days of multiple event dates' do
      date1 = subject.dates.first
      finish_at = date1.start_at + 5.days
      date1.update!(finish_at: finish_at)
      Fabricate(:event_date,
                event: subject,
                start_at: Date.new(2019, 3, 1),
                finish_at: Date.new(2019, 3, 3))
      subject.reload

      expect(subject.camp_days).to eq 9
    end
  end

  context 'camp leader checkpoints' do
    it 'resetts all checkpoints to false when camp leader is changed' do
      subject.leader_id = people(:bulei).id
      subject.save!

      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |c|
        subject.update_attribute(c, true)
      end

      subject.leader_id = people(:al_schekka).id
      subject.save!

      subject.reload

      Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |c|
        expect(subject.send(c)).to be false
      end

    end
  end

  context 'camp application' do

    it 'is not valid if camp_submitted and required value missing' do
      update_attributes(subject)
      required_attrs_for_camp_application.each do |a, v|
        subject.reload
        subject.camp_submitted = true
        expect(subject).to be_valid
        clear_attribute(subject, a)
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages.first).to match /muss ausgefüllt werden/
      end
    end

    it 'is valid if camp_submitted and all required values are present' do
      update_attributes(subject)
      subject.camp_submitted = true
      expect(subject).to be_valid
    end

    it 'is valid if camp_submitted and all required values are present, without advisor security' do
      update_attributes(subject, false)
      subject.camp_submitted = true
      expect(subject).to be_valid
    end

    def required_attrs_for_camp_application
      advisor_attributes.merge(
      { canton: 'be',
        location: 'foo',
        coordinates: '42',
        altitude: '1001',
        emergency_phone: '080011',
        landlord: 'georg',
        coach_confirmed: true,
        lagerreglement_applied: true,
        kantonalverband_rules_applied: true,
        j_s_rules_applied: true,
        expected_participants_pio_f: 3
      })
    end

    def advisor_attributes
      { coach_id: Fabricate(:person).id,
        leader_id: Fabricate(:person).id,
      }.merge(advisor_security_attributes)
    end

    def advisor_security_attributes
      { advisor_snow_security_id: [:j_s_security_snow, Fabricate(:person).id],
        advisor_mountain_security_id: [:j_s_security_mountain, Fabricate(:person).id],
        advisor_water_security_id: [:j_s_security_water, Fabricate(:person).id]
      }
    end

    def update_attributes(camp, with_advisor_security = true)
      required_attrs_for_camp_application.each do |a, v|
        unless !with_advisor_security && advisor_security_attributes.include?(a)
          attrs = {}
          if v.is_a?(Array)
            attrs[v.first] = true
            attrs[a] = v.second
          else
            attrs[a] = v
          end
          camp.update!(attrs)
        end
      end
    end

    def clear_attribute(camp, attr)
      if advisor_attributes.include?(attr)
        camp.coach_confirmed = false
        person_id = camp.send(attr)
        camp.participations.find_by(person_id: person_id).destroy!
      else
        value = camp.send(attr)
        new_value = value.is_a?(TrueClass) ? false : nil
        camp.send("#{attr}=", new_value)
      end
    end
  end

end
