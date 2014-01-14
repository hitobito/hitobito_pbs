# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Ability do

  let(:user) { role.person }
  let(:group) { role.group }
  let(:abteilung) { groups(:schekka) }

  subject { Ability.new(user.reload) }

  describe 'Bund Mitarbeiter GS' do
    let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

    it 'may update member counts' do
      should be_able_to(:update_member_counts, abteilung)
    end

    it 'may create member counts' do
      should be_able_to(:create_member_counts, abteilung)
    end

    it 'may approve population' do
      should be_able_to(:approve_population, abteilung)
    end

    it 'may view census for abteilung' do
      should be_able_to(:evaluate_census, abteilung)
    end

    it 'may view census for kantonalverband' do
      should be_able_to(:evaluate_census, abteilung.kantonalverband)
    end

    it 'may view census for bund' do
      should be_able_to(:evaluate_census, group)
    end

    it 'may remind census for kantonalverband' do
      should be_able_to(:remind_census, abteilung.kantonalverband)
    end
  end

  describe 'Kantonsleitung' do
    let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)) }

    it 'may update member counts' do
      should be_able_to(:update_member_counts, abteilung)
    end

    it 'may create member counts' do
      should be_able_to(:create_member_counts, abteilung)
    end

    it 'may approve population' do
      should be_able_to(:approve_population, abteilung)
    end

    it 'may view census for abteilung' do
      should be_able_to(:evaluate_census, abteilung)
    end

    it 'may view census for kantonalverband' do
      should be_able_to(:evaluate_census, abteilung.kantonalverband)
    end

    it 'may view census for bund' do
      should be_able_to(:evaluate_census, groups(:bund))
    end

    it 'may remind census for kantonalverband' do
      should be_able_to(:remind_census, abteilung.kantonalverband)
    end

    context 'for other kantonalverband' do
      let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:zh)) }

      it 'may not update member counts' do
        should_not be_able_to(:update_member_counts, abteilung)
      end

      it 'may not approve population' do
        should_not be_able_to(:approve_population, abteilung)
      end

      it 'may view census for abteilung' do
        should be_able_to(:evaluate_census, abteilung)
      end

      it 'may not remind census' do
        should_not be_able_to(:remind_census, abteilung.kantonalverband)
      end
    end
  end


  describe 'Abteilungsleitung' do
    let(:role) { Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: groups(:schekka)) }

    it 'may not update member counts' do
      should_not be_able_to(:update_member_counts, abteilung)
    end

    it 'may create member counts' do
      should be_able_to(:create_member_counts, abteilung)
    end

    it 'may approve population' do
      should be_able_to(:approve_population, abteilung)
    end

    it 'may view census for abteilung' do
      should be_able_to(:evaluate_census, abteilung)
    end

    it 'may view census for kantonalverband' do
      should be_able_to(:evaluate_census, abteilung.kantonalverband)
    end

    it 'may view census for bund' do
      should be_able_to(:evaluate_census, groups(:bund))
    end

    it 'may not remind census for kantonalverband' do
      should_not be_able_to(:remind_census, abteilung.kantonalverband)
    end
  end
end
