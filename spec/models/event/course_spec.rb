# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require_relative '../../support/fabrication.rb'

describe Event::Course do

  let(:event) { Fabricate(:course, groups: [groups(:be)], kind: event_kinds(:lpk)) }

  subject do
    Fabricate(Event::Role::Leader.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    Fabricate(Event::Role::AssistantLeader.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    event.reload
  end

  describe "#tentative_application_possible?" do
    Event::Course.possible_states.each do |state|
      it "is false for state #{state} when tentative_applications flag is not set" do
        expect(Event::Course.new(state: state)).not_to be_tentative_application_possible
      end
    end

    Event::Course.possible_states[0..1].each do |state|
      it "is true for state #{state} when tentative_applications flag is set" do
        expect(Event::Course.new(state: state, tentative_applications: true)).to be_tentative_application_possible
      end
    end

    Event::Course.possible_states[2..-1].each do |state|
      it "is false for state #{state} when tentative_applications flag is set" do
        expect(Event::Course.new(state: state, tentative_applications: true)).not_to be_tentative_application_possible
      end
    end
  end

  describe '.role_types' do
    subject { Event::Course.role_types }

    it { is_expected.to include(Event::Course::Role::Participant) }
    it { is_expected.not_to include(Event::Role::Participant) }
  end

  context '#application_possible?' do
    before { subject.state = 'application_open' }

    context 'without opening date' do
      it { is_expected.to be_application_possible }
    end

    context 'with opening date in the past' do
      before { subject.application_opening_at = Date.today - 1 }
      it { is_expected.to be_application_possible }

      context 'in other state' do
        before { subject.state = 'application_closed' }
        it { is_expected.not_to be_application_possible }
      end
    end

    context 'with opening ndate today' do
      before { subject.application_opening_at = Date.today }
      it { is_expected.to be_application_possible }
    end

    context 'with opening date in the future' do
      before { subject.application_opening_at = Date.today + 1 }
      it { is_expected.not_to be_application_possible }
    end

    context 'with closing date in the past' do
      before { subject.application_closing_at = Date.today - 1 }
      it { is_expected.not_to be_application_possible }
    end

    context 'in other state' do
      before { subject.state = 'created' }
      it { is_expected.not_to be_application_possible }
    end
  end

  describe '#requires_approval' do
    it 'is false if no approval group is defined' do
      expect(event.requires_approval).to be_falsy
    end

    it 'is true if all approval groups are defined' do
      event.requires_approval_abteilung = true
      event.requires_approval_region = true
      event.requires_approval_kantonalverband = true
      event.requires_approval_bund = true
      event.save!
      expect(event.requires_approval).to be_truthy
    end

    %w(requires_approval_abteilung requires_approval_region requires_approval_kantonalverband
       requires_approval_bund).each do |approval_attr|
      it "is true if .#{approval_attr} is true" do
        event.send(approval_attr + '=', true)
        event.save!
        expect(event.requires_approval).to be_truthy
      end
    end
  end

  context '#advisor' do
    let(:person)  { Fabricate(:person) }
    let(:person1) { Fabricate(:person) }

    let(:event)   { Fabricate(:pbs_course, advisor_id: person.id).reload }

    subject { event }

    its(:advisor) { should == person }
    its(:advisor_id) { should == person.id }

    it "shouldn't change the advisor if the same is already set" do
      subject.advisor_id = person.id
      expect { subject.save! }.not_to change { Event::Role.count }
      expect(subject.advisor).to eq person
    end

    it 'should update the advisor if another person is assigned' do
      event.advisor_id = person1.id
      expect(event.save).to be_truthy
      expect(event.advisor).to eq person1
    end

    it "shouldn't try to add advisor if id is empty" do
      event = Fabricate(:pbs_course, advisor_id: '')
      expect(event.advisor).to be nil
    end

    it 'removes existing advisor if id is set blank' do
      subject.advisor_id = person.id
      subject.save!

      subject.advisor_id = ''
      expect { subject.save! }.to change { Event::Role.count }.by(-1)
    end

    it 'removes existing advisor participation if id is set blank' do
      subject.advisor_id = person.id
      subject.save!

      subject.advisor_id = ''
      expect { subject.save! }.to change { Event::Participation.count }.by(-1)
    end

    it 'removes existing and creates new advisor on reassignment' do
      subject.advisor_id = person.id
      subject.save!

      new_advisor = Fabricate(:person)
      subject.advisor_id = new_advisor.id
      expect { subject.save! }.not_to change { Event::Role.count }
      expect(Event.find(subject.id).advisor_id).to eq(new_advisor.id)
      expect(subject.participations.where(person_id: person.id)).not_to be_exists
    end

  end

  context '#organizers' do
    def person(name, role)
      group = groups(name)
      Fabricate("#{group.class.name}::#{role}", group: group).person
    end

    before do
      @be_adressverwaltung = person(:be, 'Adressverwaltung')
      @be_verantwortung_ausbildung = person(:be, 'VerantwortungAusbildung')

      @zh_adressverwaltung = person(:zh, 'Adressverwaltung')
      @zh_verantwortung_ausbildung = person(:zh, 'VerantwortungAusbildung')
    end

    it 'includes people with layer_full or layer_and_below_full from organising group' do
      expect(event.organizers).to have(2).items
      expect(event.organizers).to include(@be_adressverwaltung, @be_verantwortung_ausbildung)
    end

    it 'includes people from all organising event groups' do
      event.groups << groups(:zh)
      expect(event.organizers).to have(4).items
      expect(event.organizers).to include(@be_adressverwaltung, @be_verantwortung_ausbildung,
                                          @zh_adressverwaltung, @zh_verantwortung_ausbildung)
    end
  end

end
