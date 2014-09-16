# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  group_id   :integer          not null
#  type       :string(255)      not null
#  label      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

require 'spec_helper'
describe Role do

  let(:role) { roles(:al_schekka) }


  describe 'dates' do
    let(:now) { Time.zone.parse('2014-05-03 16:32:21') }

    before do
      Time.zone.stub(now: now)
      role.update_column(:created_at, '2014-04-03 12:00:00')
    end


    context 'are valid if' do
      it 'created_at in the past' do
        role.should be_valid
      end

      it 'created_at after deleted_at in the past' do
        role.update_column(:deleted_at, '2014-04-03 14:00:00')
        role.should be_valid
      end
    end


    context 'are not valid if' do
      [:created_at, :deleted_at].each do |field|
        it "#{field} in future" do
          role.update_column(field, '2014-05-03 17:00:00')
          role.should_not be_valid
          role.should have(1).error_on(field)
        end
      end

      it 'created_at after deleted_at' do
        role.update_column(:deleted_at, '2014-04-03 11:00:00')
        role.should_not be_valid
        role.should have(1).error_on(:deleted_at)
      end

      it 'created_at has illegal format' do
        role.created_at = '303030'
        role.should_not be_valid
        role.should have(2).error_on(:created_at)
        role.created_at.should be_nil
      end

      it 'deleted_at has illegal format' do
        role.deleted_at = '303030'
        role.should_not be_valid
        role.should have(1).error_on(:deleted_at)
        role.deleted_at.should be_nil
      end
    end
  end

  context 'notification when gaining access to more person data' do
    let(:actuator)      { people(:al_schekka) }
    let(:home_group)    { groups(:schekka) }
    let(:foreign_group) { groups(:chaeib) }
    let(:person)        { Fabricate(:person, first_name: 'Asdf') }

    before { Person.stamper = actuator }
    after { Person.reset_stamper }

    it 'is sent on role creation with more access' do
      Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: foreign_group, person: person)

      role = Role.new(group_id: home_group.id,
                      person_id: person.id,
                      type: Group::Abteilung::Sekretariat.sti_name)
      expect { role.save! }.to change { Delayed::Job.count }.by(1)
      Delayed::Job.first.handler.should include('GroupMembershipJob')
    end

    it 'is not sent on role creation with equal access' do
      Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: home_group, person: person)

      role = Role.new(group_id: home_group.id,
                      person_id: person.id,
                      type: Group::Abteilung::Revisor.sti_name)
      expect { role.save! }.not_to change { Delayed::Job.count }
    end

    it 'is not sent on role creation for new person' do
      role = Role.new(group_id: home_group.id,
                      person_id: person.id,
                      type: Group::Abteilung::Sekretariat.sti_name)
      expect { role.save! }.not_to change { Delayed::Job.count }
    end

    it 'is not sent on role update (not possible to gain access via update)' do
      child_group = groups(:sunnewirbu)
      role = Fabricate(Group::Abteilung::Revisor.name.to_sym, group: home_group, person: person)

      role.type = Group::Woelfe::Wolf.sti_name
      expect { role.save! }.not_to change { Delayed::Job.count }
    end

    it 'is not sent on role destruction' do
      role = Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: home_group, person: person)

      expect { role.really_destroy! }.not_to change { Delayed::Job.count }
    end

  end

  context 'primary group (regression for #7766)' do
    let(:person) { role.person }
    before { person.update_column :primary_group_id, role.group.id }

    it 'should be reset if primary role is removed by setting deleted_at' do
      person.primary_group_id.should eq(role.group.id)

      role.deleted_at = Time.zone.now
      role.save!

      role.should be_destroyed
      person.primary_group_id.should be_nil
    end

    it 'should not be reset if secondary role is removed by setting deleted_at' do
      another_role = Fabricate(Group::Abteilung::Sekretariat.name.to_sym,
                               group: groups(:patria), person: person)

      person.primary_group_id.should eq(role.group.id)

      another_role.deleted_at = Time.zone.now
      another_role.save!

      role.should_not be_destroyed
      another_role.should be_destroyed
      person.primary_group_id.should eq role.group.id
    end
  end

end
