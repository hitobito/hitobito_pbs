#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Ability do

  let(:user) { role.person }
  let(:abteilung) { groups(:schekka) }

  subject { Ability.new(user) }

  describe 'Geschaeftsleitung' do
    let(:role) { Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)) }

    it 'may manage BlackList' do
      is_expected.to be_able_to(:manage, BlackList)
    end
  end

  describe 'Leitung Kernaufgabe Kommunikation' do
    let(:role) { Fabricate(Group::Bund::LeitungKernaufgabeKommunikation.name.to_sym, group: groups(:bund)) }

    it 'may manage BlackList' do
      is_expected.to be_able_to(:manage, BlackList)
    end
  end

  describe 'other roles' do
    it 'cannot read BlackList' do
      other_roles = Role.where.not(type: ["Group::Bund::Geschaeftsleitung",
                                           "Group::Bund::LeitungKernaufgabeKommunikation"])

      other_roles.each do |role|
        ability = Ability.new(role.person)
        expect(ability).not_to be_able_to(:read, BlackList)
        expect(ability).not_to be_able_to(:index, BlackList)
      end
    end
  end

end
