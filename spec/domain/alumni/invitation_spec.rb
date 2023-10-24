# frozen_string_literal: true

#  Copyright (c) 2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Alumni::Invitation do

  def create_role(type, group, deleted_at: nil)
    type.create!(group: group, person: person, created_at: 1.year.ago, deleted_at: deleted_at)
  end

  let(:person) { Fabricate(:person) }
  let(:role) { create_role(Group::Pfadi::Mitleitung, groups(:pegasus), deleted_at: 4.months.ago) }
  let(:ehemalige_group) { Group::Ehemalige.create!(name: 'Ehemalige', parent: groups(:schekka)) }
  let(:silverscout_group) do
    Group::SilverscoutsRegion.create!(name: 'Silverscouts Bern', parent: groups(:silverscouts))
  end

  let(:type) { :invitation }
  subject { described_class.new(role, type) }

  context '#conditions_met?' do
    conditions = [
      :feature_enabled?,
      :no_active_role_in_layer?,
      :old_enough_if_in_age_group?,
      :applicable_role?,
      :person_has_main_email?,
      :person_has_no_alumni_role?
    ]

    it 'returns true if all conditions are met' do
      conditions.each do |condition|
        allow(subject).to receive(condition).and_return(true)
      end

      expect(subject.conditions_met?).to eq true
    end

    conditions.each do |condition|
      it "returns false if #{condition} is false" do
        allow(subject).to receive(condition).and_return(false)

        expect(subject.conditions_met?).to eq false
      end
    end
  end

  context '#feature_enabled?' do
    it 'returns true if feature is enabled' do
      allow(FeatureGate).to receive(:enabled?).with('alumni.invitation').and_return(true)

      expect(subject.feature_enabled?).to eq true
    end

    it 'returns false if feature is disabled' do
      allow(FeatureGate).to receive(:enabled?).with('alumni.invitation').and_return(false)

      expect(subject.feature_enabled?).to eq false
    end
  end

  context '#no_active_role_in_layer?' do
    it 'returns true if no active role in layer' do
      expect(subject.no_active_role_in_layer?).to eq true
    end

    it 'returns false if active role in layer' do
      create_role(Group::Pfadi::Mitleitung, role.group)
      expect(subject.no_active_role_in_layer?).to eq false
    end
  end

  context '#old_enough_if_in_age_group?' do
    context 'role is in age group' do
      let(:role) { create_role(Group::Pfadi::Pfadi, groups(:pegasus)) }

      it 'returns true if person is old enough' do
        person.update!(birthday: 16.years.ago.to_date)

        expect(subject.old_enough_if_in_age_group?).to eq true
      end

      it 'returns false if person is not old enough' do
        person.update!(birthday: (16.years.ago + 1.day).to_date)

        expect(subject.old_enough_if_in_age_group?).to eq false
      end

      it 'returns false if person has no birthday' do
        person.update!(birthday: nil)

        expect(subject.old_enough_if_in_age_group?).to eq false
      end
    end

    context 'role is not in age group' do
      let(:role) { create_role(Group::Abteilung::Abteilungsleitung, groups(:schekka)) }

      it 'returns true if person is old enough' do
        person.update!(birthday: 16.years.ago.to_date)

        expect(subject.old_enough_if_in_age_group?).to eq true
      end

      it 'returns true if person is not old enough' do
        person.update!(birthday: (16.years.ago + 1.day).to_date)

        expect(subject.old_enough_if_in_age_group?).to eq true
      end

      it 'returns true if person has no birthday' do
        person.update!(birthday: nil)

        expect(subject.old_enough_if_in_age_group?).to eq true
      end
    end
  end

  context '#applicable_role?' do
    it 'returns false if role is ehemalige role' do
      role = create_role(Group::Ehemalige::Mitglied, ehemalige_group, deleted_at: 5.months.ago)
      expect(described_class.new(role, :invitation).applicable_role?).to eq false
    end

    it 'returns false if role group is silverscout group' do
      role = create_role(Group::SilverscoutsRegion::Mitglied, silverscout_group,
                         deleted_at: 5.months.ago)
      expect(described_class.new(role, :invitation).applicable_role?).to eq false
    end

    it 'returns false if role group is root group' do
      role = create_role(Group::Root::Admin, groups(:root), deleted_at: 5.months.ago)
      expect(described_class.new(role, :invitation).applicable_role?).to eq false
    end

    it 'returns true if role is not ehemalige role, not silverscout group and not root group' do
      role = create_role(Group::Pfadi::Mitleitung, groups(:pegasus), deleted_at: 5.months.ago)
      expect(described_class.new(role, :invitation).applicable_role?).to eq true
    end
  end

  context '#person_has_main_email?' do
    it 'returns true if person has main email' do
      role.person.email = 'person@example.com'

      expect(subject.person_has_main_email?).to eq true
    end

    it 'returns false if person has no main email' do
      role.person.email = nil

      expect(subject.person_has_main_email?).to eq false
    end
  end

  context '#person_has_no_alumni_role?' do
    it 'returns false if person has ehemalige role' do
      create_role(Group::Ehemalige::Mitglied, ehemalige_group)
      expect(subject.person_has_no_alumni_role?).to eq false
    end

    it 'returns false if person has silverscout role' do
      create_role(Group::SilverscoutsRegion::Mitglied, silverscout_group)
      expect(subject.person_has_no_alumni_role?).to eq false
    end

    it 'returns false if person has root role' do
      create_role(Group::Root::Admin, groups(:root))
      expect(subject.person_has_no_alumni_role?).to eq false
    end

    it 'returns true if person has no ehemalige, silverscout or root role' do
      create_role(Group::Abteilung::Abteilungsleitung, groups(:schekka))
      expect(subject.person_has_no_alumni_role?).to eq true
    end
  end

  context '#process' do
    [:invitation, :reminder].each do |mail_type|
      let(:type) { mail_type }

      context "for type=#{mail_type}" do
        context 'if conditions are met' do
          it 'sets timestamp' do
            timestamp_attr = "alumni_#{type}_processed_at"

            freeze_time do
              expect { subject.process }.to change {
                                              role.reload.send(timestamp_attr)
                                            }.to Time.zone.now
            end
          end

          it 'sends email' do
            ex_members_group_ids = [instance_double(Group), instance_double(Group)]
            silverscout_group_ids = [instance_double(Group), instance_double(Group)]
            groups_finder = instance_double(Alumni::ApplicableGroups,
                                            ex_members_group_ids: ex_members_group_ids, silverscout_group_ids: silverscout_group_ids)

            mail = double('mail')
            expect(mail).to receive(:deliver_later)

            expect(AlumniMailer).to receive(type).with(role.person, ex_members_group_ids,
                                                       silverscout_group_ids).and_return(mail)

            invitation = described_class.new(role, type, groups_finder)
            expect(invitation).to receive(:conditions_met?).and_return(true)
            invitation.process
          end
        end

        context 'if conditions are not met' do
          it 'sets timestamp' do
            timestamp_attr = "alumni_#{type}_processed_at"

            freeze_time do
              expect { subject.process }.to change {
                                              role.reload.send(timestamp_attr)
                                            }.to Time.zone.now
            end
          end

          it 'does not send email' do
            expect(AlumniMailer).not_to receive(:send)

            subject.process
          end
        end
      end
    end
  end
end
