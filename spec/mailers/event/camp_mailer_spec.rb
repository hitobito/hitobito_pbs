# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::CampMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  let(:camp) do
    camp = Fabricate(:pbs_camp, groups: [groups(:sunnewirbu)], name: 'Wirbelcamp')
    camp.update_attributes(coach_id: coach.id)
    camp
  end
  let(:camp_url) { group_event_url(camp.groups.first, camp) }
  let(:recipient) { people(:al_schekka) }
  let(:recipients) { [people(:al_schekka)] }
  let(:actuator) do
    actuator = Fabricate(Group::Woelfe::Einheitsleitung.name.to_sym,
                         group: groups(:sunnewirbu)).person
    actuator.update_attributes(first_name: 'Wirbel', last_name: 'Sturm')
    actuator
  end
  let(:coach) do
    coach = Fabricate(Group::Woelfe::Wolf.name.to_sym, group: groups(:sunnewirbu)).person
    coach.update_attributes(first_name: 'Heftige', last_name: 'Böe')
    coach
  end
  let(:other_person) do
    other_person = Fabricate(Group::Woelfe::Wolf.name.to_sym,
                             group: groups(:sunnewirbu)).person
    other_person.update_attributes(first_name: 'Wind', last_name: 'Hose')
    other_person
  end
  let(:participation) { Fabricate(:event_participation, person: other_person, event: camp) }

  [{ method: :created_info,
     args: [:camp, :recipients, :actuator],
     subject: 'Lager wurde erstellt',
     body: /Das Lager \"Wirbelcamp\" wurde von Wirbel Sturm.*erstellt/ },
   { method: :coach_assigned_info,
     args: [:camp, :recipients, :actuator],
     subject: 'Lager: Coach zugeordnet',
     body: /Wirbel Sturm.*hat im Lager \"Wirbelcamp\" Heftige Böe.*als Coach definiert/ },
   { method: :security_advisor_assigned_info,
     args: [:camp, :recipients, :actuator, :other_person],
     subject: 'Lager: Sicherheitsbereich Betreuung zugeordnet',
     body: /Wirbel Sturm.* hat im Lager \"Wirbelcamp\" Wind Hose.*als Sicherheitsbereich Betreuung definiert/ },
   { method: :al_assigned_info,
     args: [:camp, :recipients, :actuator],
     subject: 'Lager: Abteilungsleitung zugeordnet',
     body: /Wirbel Sturm.*hat im Lager \"Wirbelcamp\"  als Abteilungsleitung definiert/ },
   { method: :remind,
     args: [:camp, :recipient],
     subject: 'Lager: Lager einreichen Erinnerung',
     body: /Das Lager \"Wirbelcamp\" muss noch an PBS eingereicht werden/ },
   { method: :submit,
     args: [:camp, :recipient, :actuator],
     subject: 'Einreichung Lager',
     body: /Wirbel Sturm.*reicht das Lager \"Wirbelcamp\" ein.*PDF: http.*\/camp_application/ },
   { method: :participant_applied_info,
     args: [:participation, :recipients],
     subject: 'Lager: Teilnehmer-/in hat sich angemeldet',
     body: /Wind Hose.*hat sich für das Lager \"Wirbelcamp\" angemeldet/ },
   { method: :participant_canceled_info,
     args: [:participation, :recipients],
     subject: 'Lager: Teilnehmer-/in hat sich abgemeldet',
     body: /Wind Hose.*hat sich vom Lager \"Wirbelcamp\" abgemeldet/ }
  ].each do |action|
    context "##{action[:method]}" do
      let(:mail) do
        Event::CampMailer.send(action[:method], *action[:args].map { |arg| self.send arg })
      end

      context 'headers' do
        subject { mail }
        its(:subject) { should eq action[:subject] }
        its(:to)      { should eq ['al.schekka@hitobito.example.com'] }
        its(:from)    { should eq ['noreply@localhost'] }
      end

      context 'body' do
        subject { mail.body }

        it 'renders placeholders' do
          is_expected.to match(action[:body])
          is_expected.to match(camp_url)
        end
      end
    end
  end
end
