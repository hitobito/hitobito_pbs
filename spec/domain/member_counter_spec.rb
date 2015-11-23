# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe MemberCounter do

  let(:abteilung) { groups(:schekka) }

  before do
    woelfe = groups(:sunnewirbu)
    pfadi1 = groups(:pegasus)
    pfadi2 = groups(:baereried)
    leader = Fabricate(Group::Abteilung::StufenleitungPfadi.name, group: abteilung, person: Fabricate(:person, gender: 'w', birthday: '1985-01-01'))
    rover = Fabricate(Group::AbteilungsRover::Rover.name, group: groups(:rovers), person: Fabricate(:person, gender: 'm', birthday: '1989-01-01'))
    Fabricate(Group::Pfadi::Einheitsleitung.name, group: pfadi1, person: Fabricate(:person, gender: 'w', birthday: '1988-01-01'))
    Fabricate(Group::Pfadi::Einheitsleitung.name, group: pfadi2, person: rover.person)
    Fabricate(Group::Pfadi::Leitpfadi.name, group: pfadi1, person: Fabricate(:person, gender: 'w', birthday: '1999-01-01'))
    Fabricate(Group::Pfadi::Pfadi.name, group: pfadi1, person: Fabricate(:person, gender: 'm', birthday: '1999-01-01'))
    puecki = Fabricate(Group::Pfadi::Pfadi.name, group: pfadi2, person: Fabricate(:person, gender: 'w', birthday: '1999-02-02'))
    Fabricate(Group::Woelfe::Wolf.name, group: woelfe, person: Fabricate(:person, gender: 'w', birthday: '2002-02-02'))
    Fabricate(Group::Woelfe::Leitwolf.name, group: woelfe, person: puecki.person)
    # external roles, not counted
    Fabricate(Group::Pfadi::Adressverwaltung.name, group: pfadi2, person: Fabricate(:person, gender: 'm', birthday: '1971-01-01'))
    Fabricate(Group::Abteilung::Webmaster.name, group: abteilung, person: Fabricate(:person, gender: 'w', birthday: '1972-01-01'))
    Fabricate(Group::Abteilung::Passivmitglied.name, group: abteilung, person: Fabricate(:person, gender: 'w', birthday: '1972-01-01'))
    old = Fabricate(Group::Abteilung::Abteilungsleitung.name, group: abteilung, person: Fabricate(:person, gender: 'w', birthday: '1977-03-01'), created_at: 2.years.ago)
    old.destroy # soft delete role
  end

  it 'abteilung has passive and deleted people as well' do
    expect(abteilung.people.count).to eq(4)
    expect(Person.joins('INNER JOIN roles ON roles.person_id = people.id').
           where(roles: { group_id: abteilung.id }).
           count).to eq(5)
  end

  context 'instance' do

    subject { MemberCounter.new(2011, abteilung) }

    it { is_expected.not_to be_exists }

    its(:kantonalverband) { should == groups(:be) }

    its(:region) { should == groups(:bern) }

    its(:members) { should have(9).items }

    it 'creates member counts' do
      expect { subject.count! }.to change { MemberCount.count }.by(1)

      is_expected.to be_exists

      assert_member_counts(leiter_f: 3, leiter_m: 1,
                           pfadis_f: 3, pfadis_m: 1,
                           woelfe_f: 1)
    end

  end

  context '.create_count_for' do
    it 'creates count with current census' do
      censuses(:two_o_12).destroy
      expect { MemberCounter.create_counts_for(abteilung) }.to change { MemberCount.where(year: 2011).count }.by(1)
    end

    it 'does not create counts with existing ones' do
      expect { MemberCounter.create_counts_for(abteilung) }.not_to change { MemberCount.count }
    end

    it 'does not create counts without census' do
      Census.destroy_all
      expect { MemberCounter.create_counts_for(abteilung) }.not_to change { MemberCount.count }
    end
  end

  context '.current_counts?' do
    subject { MemberCounter.current_counts?(abteilung) }

    context 'with counts' do
      it { is_expected.to be_truthy }
    end

    context 'without counts' do
      before { MemberCount.update_all(year: 2011) }
      it { is_expected.to be_falsey }
    end

    context 'with census' do
      before { Census.destroy_all }
      it { is_expected.to be_falsey }
    end
  end

  def assert_member_counts(fields = {})
    count = MemberCount.where(abteilung_id: abteilung.id, year: 2011).first
    MemberCount::COUNT_COLUMNS.each do |c|
      expected = fields[c.to_sym] || 0
      expect(count.send(c).to_i).to be(expected), "#{c} should be #{expected}, was #{count.send(c).to_i}"
    end
  end

  context 'members_per_birthyear' do

    subject { MemberCounter.new(2011, abteilung).members_per_birthyear }

    it 'counts all active members' do
      expect(subject.map(&:count).sum).to eq(9)
    end

    it 'counts correct amount of members per year' do
      expect(subject.select{|y| y.year == 1999}[0].count).to eq(3)
      expect(subject.select{|y| y.year == 1988}[0].count).to eq(1)
    end

    it 'counts nil birthdays' do
      expect(subject.select{|y| y.year.nil?}[0].count).to eq(2)
    end

    it 'works with only nil birthdays' do
      Person.where('birthday IS NOT NULL').delete_all
      expect(subject[0].count).to eq(2)
    end

    it 'works if no people present' do
      Person.delete_all
      expect(subject).to be_empty
    end

    it 'doesn\'t show counted nils if there are none' do
      Person.where('birthday IS NULL').delete_all
      expect(subject.select{|y| y.year.nil?}).to be_empty
    end

    it 'gives count relative to maximum count' do
      expect(subject.select{|y| y.year == 1999}[0].count_relative).to eq(1)
      expect(subject.select{|y| y.year == 1988}[0].count_relative).to eq(1.0/3)
    end
  end

end
