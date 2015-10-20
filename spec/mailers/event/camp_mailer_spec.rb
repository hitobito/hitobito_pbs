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

  let(:camp) { Fabricate(:pbs_camp, groups: [groups(:sunnewirbu)], name: 'Wirbelcamp') }
  let(:camp_url) { group_event_url(camp.groups.first, camp) }
  let(:recipient) { people(:al_schekka) }
  let(:recipients) { [people(:al_schekka)] }
  let(:actuator) do
    actuator = Fabricate(Group::Woelfe::Einheitsleitung.name.to_sym,
                         group: groups(:sunnewirbu)).person
    actuator.update_attributes(first_name: 'Wirbel', last_name: 'Sturm')
    actuator
  end
  let(:actuator_id) { actuator.id }
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

  before do
    camp.update_attributes(coach_id: coach.id)
  end

  describe '#camp_created' do
    let(:mail) { Event::CampMailer.camp_created(camp, recipients, actuator.id) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Lager wurde erstellt' }
      its(:to)      { should eq ['al.schekka@hitobito.example.com'] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Das Lager \"Wirbelcamp\" wurde von Wirbel Sturm.*erstellt/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe '#advisor_assigned' do
    context 'coach' do
      let(:mail) { Event::CampMailer.advisor_assigned(camp, coach, 'coach', actuator_id) }

      context 'headers' do
        subject { mail }
        its(:subject) { should eq 'Lager: Coach zugeordnet' }
        its(:to)      { should eq [coach.email] }
        its(:from)    { should eq ['noreply@localhost'] }
      end

      context 'body' do
        subject { mail.body }

        it 'renders placeholders' do
          is_expected.to match(/Wirbel Sturm.*hat im Lager \"Wirbelcamp\" Heftige Böe.*als Coach definiert/)
          is_expected.to match(camp_url)
        end
      end
    end

    context 'advisor' do
      let(:mail) { Event::CampMailer.advisor_assigned(camp, other_person, 'advisor', actuator_id) }

      context 'headers' do
        subject { mail }
        its(:subject) { should eq 'Lager: Sicherheitsbereich Betreuung zugeordnet' }
        its(:to)      { should eq [other_person.email] }
        its(:from)    { should eq ['noreply@localhost'] }
      end

      context 'body' do
        subject { mail.body }

        it 'renders placeholders' do
          is_expected.to match(/Wirbel Sturm.* hat im Lager \"Wirbelcamp\" Wind Hose.*als Sicherheitsbereich Betreuung definiert/)
          is_expected.to match(camp_url)
        end
      end
    end

    context 'abteilungsleitung' do
      let(:mail) { Event::CampMailer.advisor_assigned(camp, other_person, 'abteilungsleitung', actuator_id) }

      context 'headers' do
        subject { mail }
        its(:subject) { should eq 'Lager: Abteilungsleitung zugeordnet' }
        its(:to)      { should eq [other_person.email] }
        its(:from)    { should eq ['noreply@localhost'] }
      end

      context 'body' do
        subject { mail.body }

        it 'renders placeholders' do
          is_expected.to match(/Wirbel Sturm.*hat im Lager \"Wirbelcamp\" Wind Hose.*als Abteilungsleitung definiert/)
          is_expected.to match(camp_url)
        end
      end
    end
  end


  describe '#remind' do
    let(:mail) { Event::CampMailer.remind(camp, recipient) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Lager: Lager einreichen Erinnerung' }
      its(:to)      { should eq ['al.schekka@hitobito.example.com'] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Das Lager \"Wirbelcamp\" muss noch an PBS eingereicht werden/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe '#submit_camp' do
    let(:mail) { Event::CampMailer.submit_camp(camp) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Einreichung Lager' }
      # its(:to)      { should eq ['al.schekka@hitobito.example.com'] }
      # its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Heftige Böe.*reicht das Lager \"Wirbelcamp\" ein.*PDF: http.*\/camp_application/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe '#participant_applied_info' do
    let(:mail) { Event::CampMailer.participant_applied_info(participation, recipients) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Lager: Teilnehmer-/in hat sich angemeldet' }
      its(:to)      { should eq ['al.schekka@hitobito.example.com'] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Wind Hose.*hat sich für das Lager \"Wirbelcamp\" angemeldet/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe '#participant_canceled_info' do
    let(:mail) { Event::CampMailer.participant_canceled_info(participation, recipients) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Lager: Teilnehmer-/in hat sich abgemeldet' }
      its(:to)      { should eq ['al.schekka@hitobito.example.com'] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Wind Hose.*hat sich vom Lager \"Wirbelcamp\" abgemeldet/)
        is_expected.to match(camp_url)
      end
    end
  end
end
