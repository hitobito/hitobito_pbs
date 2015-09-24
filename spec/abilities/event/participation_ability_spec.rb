# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationAbility do

  subject { Ability.new(role.person.reload) }

  context 'in abteilung' do
    let(:group) { groups(:schekka) }

    context 'abteilungsleitung' do
      let(:role) { Fabricate(Group::Abteilung::Abteilungsleitung.name, group: group) }

      it "is allowed to manage event participation" do
        event = Fabricate(:event, groups: [group])
        participation = Fabricate(:event_participation, event: event)
        role = Fabricate(Event::Role::Leader.name, participation: participation)
        is_expected.to be_able_to(:show, participation)
        is_expected.to be_able_to(:show_details, participation)
        is_expected.to be_able_to(:print, participation)
        is_expected.to be_able_to(:update, participation)
        is_expected.to be_able_to(:create, participation)
        is_expected.to be_able_to(:destroy, participation)
        is_expected.to be_able_to(:update, role)
        is_expected.to be_able_to(:create, role)
        is_expected.to be_able_to(:destroy, role)
      end

      it "is not allowed to manage course participation" do
        event = Fabricate(:pbs_course, groups: [group])
        participation = Fabricate(:event_participation, event: event)
        role = Fabricate(Event::Course::Role::Leader.name, participation: participation)
        is_expected.not_to be_able_to(:show, participation)
        is_expected.not_to be_able_to(:show_details, participation)
        is_expected.not_to be_able_to(:print, participation)
        is_expected.not_to be_able_to(:update, participation)
        is_expected.not_to be_able_to(:create, participation)
        is_expected.not_to be_able_to(:destroy, participation)
        is_expected.not_to be_able_to(:update, role)
        is_expected.not_to be_able_to(:create, role)
        is_expected.not_to be_able_to(:destroy, role)
      end

      it 'is allowed to show course participation from same layer' do
        event = Fabricate(:pbs_course, groups: [group])
        person = Fabricate(Group::Pfadi::Pfadi.name, group: groups(:pegasus)).person
        participation = Fabricate(:event_participation, event: event, person: person, application: Fabricate(:pbs_application))
        is_expected.to be_able_to(:show, participation)
        is_expected.to be_able_to(:show_approval, participation.application)
        is_expected.not_to be_able_to(:show_details, participation)
        is_expected.not_to be_able_to(:update, participation)
      end
    end

    context 'as regionalleitung' do
      let(:role) { Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern)) }

      it "is allowed to manage event participation" do
        event = Fabricate(:event, groups: [group])
        participation = Fabricate(:event_participation, event: event)
        role = Fabricate(Event::Role::Leader.name, participation: participation)
        is_expected.to be_able_to(:show, participation)
        is_expected.to be_able_to(:show_details, participation)
        is_expected.to be_able_to(:print, participation)
        is_expected.to be_able_to(:update, participation)
        is_expected.not_to be_able_to(:create, participation)
        is_expected.not_to be_able_to(:destroy, participation)
        is_expected.to be_able_to(:update, role)
        is_expected.to be_able_to(:create, role)
        is_expected.to be_able_to(:destroy, role)
      end

      it "is allowed to manage course participation" do
        event = Fabricate(:pbs_course, groups: [group])
        participation = Fabricate(:event_participation, event: event)
        role = Fabricate(Event::Course::Role::Leader.name, participation: participation)
        is_expected.to be_able_to(:show, participation)
        is_expected.to be_able_to(:show_details, participation)
        is_expected.to be_able_to(:print, participation)
        is_expected.to be_able_to(:update, participation)
        is_expected.to be_able_to(:create, participation)
        is_expected.to be_able_to(:destroy, participation)
        is_expected.to be_able_to(:update, role)
        is_expected.to be_able_to(:create, role)
        is_expected.to be_able_to(:destroy, role)
      end
    end

  end
end
