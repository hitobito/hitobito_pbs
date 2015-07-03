# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventAbility do

  let(:user)    { role.person }
  let(:group)   { groups(:be) }
  let(:event)   { Fabricate(:event, groups: [group]) }

  def ability(person)
    Ability.new(person.reload)
  end

  def create(event_role_type, person)
    participation = Fabricate(:event_participation, person: person, event: event)
    Fabricate(event_role_type.name, participation: participation)
  end

  context 'index_participations_details on event in group ' do
    it 'Group::Bund::MitarbeiterGs is allowed because of :layer_and_below_full' do
      expect(ability(people(:bulei))).to be_able_to(:index_participations_details, event)
    end

    it 'Group::Kantonalverband::Kantonsleitung is allowed because of :group_full' do
      person = Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: group).person
      expect(ability(person)).to be_able_to(:index_participations_details, event)
    end

    it 'Group::Abteilung::Abteilungsleitung with leader role is allowed' do
      person = people(:al_schekka)
      create(Event::Role::Leader, person)

      expect(ability(person)).to be_able_to(:index_participations_details, event)
    end

    it 'Group::Abteilung::Abteilungsleitung with participation role is not allowed' do
      person = people(:al_schekka)
      create(Event::Role::Participant, person)

      expect(ability(person)).not_to be_able_to(:index_participations_details, event)
    end
  end

end
