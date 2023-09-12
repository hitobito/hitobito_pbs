# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PersonDecorator do

  let(:decorator) { PersonDecorator.new(person) }

  let(:layer) { Fabricate(Group::Abteilung.name) }

  let(:person) { Fabricate(:person) }
  let(:person_group) { Fabricate(Group::Pfadi.name, parent: layer)}
  let!(:person_role) { Fabricate(person_group.default_role.name, person: person, group: person_group) }

  let(:sibling) { Fabricate(:person) }
  let(:sibling_group) { Fabricate(Group::Woelfe.name, parent: layer)}
  let!(:sibling_role) { Fabricate(sibling_group.default_role.name, person: sibling, group: sibling_group) }

  let!(:sibling_relation) { Fabricate(:family_member, person: person, other: sibling, kind: :sibling) }

  describe '#siblings_in_layer' do

    subject do
      decorator.siblings_in_layer(person_group)
    end

    context 'without siblings' do
      let!(:sibling_relation) { nil }
      it { is_expected.to be_empty }
    end

    context 'with siblings in different groups' do
      let(:sibling_group) { Fabricate(Group::Woelfe.name, parent: Fabricate(Group::Abteilung.name))}
      it { is_expected.to be_empty }
    end

    context 'with siblings in same group' do
      let(:sibling_group) { person_group }
      it { is_expected.to contain_exactly(sibling_role) }
    end

    context 'with siblings in same layer' do
      it { is_expected.to contain_exactly(sibling_role) }
    end

    context 'with siblings with deleted role in same group' do
      let!(:sibling_role) do  
        Fabricate(sibling_group.default_role.name, person: sibling, group: sibling_group, 
                                                   created_at: 2.months.ago, deleted_at: 1.month.ago)
      end
      it { is_expected.to be_empty }
    end

  end

end
