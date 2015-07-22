# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventAbility do

  def ability(person)
    Ability.new(person.reload)
  end

  context 'event creation/update/list_tentatives' do
    allowed_roles = [
      # abteilung
      [:patria, 'Abteilungsleitung'],
      [:patria, 'AbteilungsleitungStv'],
      [:patria, 'Sekretariat'],
      # kantonalverband
      [:be, 'Kantonsleitung'],
      [:be, 'VerantwortungAusbildung'],
      [:be, 'Sekretariat'],
      # region
      [:bern, 'Regionalleitung'],
      [:bern, 'VerantwortungAusbildung'],
      [:bern, 'Sekretariat'],
      # bund
      [:bund, 'MitarbeiterGs'],
      [:bund, 'Sekretariat'],
      [:bund, 'AssistenzAusbildung']
    ]

    allowed_roles.each do |r|

      it "#{r.second} should be allowed to create/update event in group #{r.first.to_s}" do
        group = groups(r.first)
        role_name = group.class.name + '::' + r.second
        person = Fabricate(role_name, group: group).person
        event = Fabricate(:event, groups: [group])
        expect(ability(person)).to be_able_to(:create, event)
        expect(ability(person)).to be_able_to(:update, event)
      end

      it "#{r.second} should be allowed to list_tentatives for event in group #{r.first.to_s}" do
        group = groups(r.first)
        role_name = group.class.name + '::' + r.second
        person = Fabricate(role_name, group: group).person
        event = Fabricate(:pbs_course, groups: [group], tentative_applications: true)

        expect(ability(person)).to be_able_to(:list_tentatives, event)
      end

      it "#{r.second} should be allowed to index_revoked_participations for event in group #{r.first.to_s}" do
        group = groups(r.first)
        role_name = group.class.name + '::' + r.second
        person = Fabricate(role_name, group: group).person
        event = Fabricate(:pbs_course, groups: [group])

        expect(ability(person)).to be_able_to(:index_revoked_participations, event)
      end
    end
  end

  context 'permissions' do
    subject { ability }
    let(:ability) { Ability.new(role.person.reload) }

    context 'mitarbeiter gs' do
      let(:role) { Fabricate(Group::Bund::MitarbeiterGs.name.to_sym, group: groups(:bund)) }

      context 'in bund' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context 'in kanton' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end

    context 'mitarbeiter gs' do
      let(:role) { Fabricate(Group::Bund::AssistenzAusbildung.name.to_sym, group: groups(:bund)) }

      context 'in bund' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context 'in kanton' do
        it 'may modify superior attributes' do
          is_expected.to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end

    context 'sekretariat' do
      let(:role) { Fabricate(Group::Bund::Sekretariat.name.to_sym, group: groups(:bund)) }

      context 'in bund' do
        it 'may modify superior attributes' do
          is_expected.not_to be_able_to(:modify_superior, events(:bund_course))
        end
      end

      context 'in kanton' do
        it 'may modify superior attributes' do
          is_expected.not_to be_able_to(:modify_superior, events(:top_course))
        end
      end
    end
  end

end
