#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Ability do

  subject { Ability.new(role.person) }

  describe 'Group::Bund::VerantwortungKrisenteam' do
    let(:role)   { Fabricate("Group::Bund::VerantwortungKrisenteam".to_sym, group: groups(:bund)) }

    context 'Bund' do
      let(:crisis) { groups(:bund).crises.build }
      it 'may create and update crisis' do
        expect(subject).to be_able_to(:create, crisis)
        expect(subject).to be_able_to(:update, crisis)
      end
    end

    context 'Kanton' do
      let(:crisis) { groups(:be).crises.build }
      it 'may create and update crisis' do
        expect(subject).to be_able_to(:create, crisis)
        expect(subject).to be_able_to(:update, crisis)
      end
    end

    context 'Abteilung' do
      let(:crisis) { groups(:schekka).crises.build }
      it 'may create and update crisis' do
        expect(subject).to be_able_to(:create, crisis)
        expect(subject).to be_able_to(:update, crisis)
      end
    end

    context 'KantonalesGremium' do
      let(:crisis) { groups(:fg_security).crises.build }
      it 'may not create and update crisis' do
        expect(subject).not_to be_able_to(:create, crisis)
        expect(subject).not_to be_able_to(:update, crisis)
      end
    end
  end

  describe 'Group::Kantonalverband::VerantwortungKrisenteam' do
    let(:role)   { Fabricate("Group::Kantonalverband::VerantwortungKrisenteam".to_sym, group: groups(:be)) }

    context 'Kanton' do
      let(:crisis) { groups(:be).crises.build }
      it 'may not create and update crisis' do
        expect(subject).not_to be_able_to(:create, crisis)
        expect(subject).not_to be_able_to(:update, crisis)
      end
    end

    context 'Bund' do
      let(:crisis) { groups(:bund).crises.build }
      it 'may not create and update crisis' do
        expect(subject).not_to be_able_to(:create, crisis)
        expect(subject).not_to be_able_to(:update, crisis)
      end
    end

    context 'KantonalesGremium' do
      let(:crisis) { groups(:fg_security).crises.build }
      it 'may not create and update crisis' do
        expect(subject).not_to be_able_to(:create, crisis)
        expect(subject).not_to be_able_to(:update, crisis)
      end
    end

    context 'Abteilung' do
      let(:crisis) { groups(:schekka).crises.build }
      it 'may create and update crisis' do
        expect(subject).to be_able_to(:create, crisis)
      end
    end

    context 'Abteilung in different Kanton' do
      let(:crisis) { groups(:chaeib).crises.build }
      it 'may not create and update crisis' do
        expect(subject).not_to be_able_to(:create, crisis)
        expect(subject).not_to be_able_to(:update, crisis)
      end
    end
  end

end
