# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationAbility do

  let(:event)   { events(:top_course) }
  let(:participation) { event_participations(:top_participant) }

  context ':completed_approvals' do
    before { participation.create_application(priority_1: event) }

    it "Bundesleitung may list approvals" do
      expect(ability(people(:bulei))).to be_able_to(:completed_approvals, participation)
    end

    it "Kantonsleitung may list approvals" do
      person = Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: event.groups.first).person
      expect(ability(person)).to be_able_to(:completed_approvals, participation)
    end

    it "course leader may list approvals" do
      expect(ability(event_participations(:top_leader).person)).to be_able_to(:completed_approvals, participation)
    end

    it "participant may never list his own approvals" do
      Fabricate(Event::Role::Leader.name, event: event, participation: participation)
      expect(ability(participation.person.reload)).not_to be_able_to(:completed_approvals, participation)
    end
  end


  private

  def ability(person)
    Ability.new(person)
  end

end
