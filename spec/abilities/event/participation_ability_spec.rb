# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationAbility do

  def build(attrs)
    course = Event::Course.new(groups: attrs.fetch(:groups).map { |g| groups(g) } , tentative_applications: true)
    @participation = Event::Participation.new(event: course, person: attrs[:person])
  end

  let(:participation) { @participation }

  context 'participation without person' do
    subject { Ability.new(people(:al_schekka)) }

    it 'may create_tentative for event higher up in organisation' do
      is_expected.to be_able_to(:create_tentative, build(groups: [:bern]))
    end

    it 'may create_tentative for event further down in organisation' do
      is_expected.to be_able_to(:create_tentative, build(groups: [:rovers]))
    end

    it 'may not create_tentative for event in different branch and higher layer of organisation' do
      is_expected.not_to be_able_to(:create_tentative, build(groups: [:zh]))
    end

    it 'may create_tentative for event if one of the groups is permitted' do
      is_expected.to be_able_to(:create_tentative, build(groups: [:be, :zh]))
    end

    it 'may not create_tentative for event in different branch but same layer of organisation' do
      is_expected.not_to be_able_to(:create_tentative, build(groups: [:berchtold]))
    end
  end

  context 'participation with person' do

    context 'Abteilungsleiter with layer_and_below_full' do
      subject { Ability.new(people(:al_schekka)) }

      it 'may not create_tentative for person in upper layer' do
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:be], person: people(:bulei)))
      end

      it 'may create_tentative for person in his group' do
        person = Fabricate(Group::Abteilung::Praeses.name, group: groups(:schekka)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:be], person: person))
      end

      it 'may not create_tentative for person in different group on same layer' do
        person = Fabricate(Group::Abteilung::Praeses.name, group: groups(:patria)).person
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:be], person: person))
      end

      it 'may create_tentative for person in layer below' do
        person = Fabricate(Group::Woelfe::Leitwolf.name, group: groups(:sunnewirbu)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:be], person: person))
      end
    end

    context 'Region AssistenzAusbildung with layer_full' do
      subject { Ability.new(Fabricate(Group::Region::VerantwortungAusbildung.name, group: groups(:bern)).person) }

      it 'may not create_tentative for person in upper layer' do
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:be], person: people(:bulei)))
      end

      it 'may create_tentative for person in his group' do
        person = Fabricate(Group::Region::Revisor.name, group: groups(:bern)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:be], person: person))
      end

      it 'may not create_tentative for person in layer below' do
        person = Fabricate(Group::Abteilung::Praeses.name, group: groups(:schekka)).person
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:be], person: person))
      end
    end

    context 'Woelfe AssistenzAusbildung with group_full' do
      subject { Ability.new(Fabricate(Group::Woelfe::Adressverwaltung.name, group: groups(:sunnewirbu)).person) }

      it 'may not create_tentative for person in upper layer' do
        is_expected.not_to be_able_to(:create_tentative, build(groups: [:be], person: people(:al_schekka)))
      end

      it 'may create_tentative for person in his group' do
        person = Fabricate(Group::Woelfe::Leitwolf.name, group: groups(:sunnewirbu)).person
        is_expected.to be_able_to(:create_tentative, build(groups: [:be], person: person))
      end
    end
  end
end
