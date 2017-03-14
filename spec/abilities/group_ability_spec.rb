# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'


describe GroupAbility do

  subject { ability }
  let(:ability) { Ability.new(role.person.reload) }


  context 'mitarbeiter gs' do
    let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

    context 'in bund' do
      it 'may modify superior attributes' do
        is_expected.to be_able_to(:modify_superior, groups(:bund))
      end
    end

    context 'in kanton' do
      it 'may modify superior attributes' do
        is_expected.to be_able_to(:modify_superior, groups(:be))
      end
    end

    context 'in abteilung' do
      it 'may modify superior attributes' do
        is_expected.to be_able_to(:modify_superior, groups(:schekka))
      end
    end
  end

  context 'kantonsleitung' do
    let(:role) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)) }

    context 'in kanton' do
      it 'may not modify superior attributes' do
        is_expected.not_to be_able_to(:modify_superior, groups(:be))
      end
    end

    context 'in abteilung' do
      it 'may not modify superior attributes' do
        is_expected.not_to be_able_to(:modify_superior, groups(:schekka))
      end
    end
  end

  context 'ausbildungsveranwortlicher' do
    let(:role) { Fabricate(Group::Kantonalverband::VerantwortungAusbildung.name.to_sym, group: groups(:be)) }

    context 'in own kanton' do
      it 'may see pending approvals' do
        is_expected.to be_able_to(:pending_approvals, groups(:be))
      end
    end

    context 'in other kanton' do
      it 'may not see pending approvals' do
        is_expected.to_not be_able_to(:pending_approvals, groups(:zh))
      end
    end
  end

end
