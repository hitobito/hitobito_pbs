# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

equire 'spec_helper'
require_relative '../../support/fabrication.rb'

describe Event::Course do

  subject do
    event = Fabricate(:jubla_course, groups: [groups(:be)])
    Fabricate(Event::Role::Leader.name.to_sym, participation: Fabricate(:event_participation, event: event))
    Fabricate(Event::Role::AssistantLeader.name.to_sym, participation: Fabricate(:event_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym, participation: Fabricate(:event_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym, participation: Fabricate(:event_participation, event: event))
    event.reload
  end

  describe '.role_types' do
    subject { Event::Course.role_types }

    it { is_expected.to include(Event::Course::Role::Participant) }
    it { is_expected.to include(Event::Course::Role::Advisor) }
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

    context 'with ng date today' do
      before { subject.application_opening_at = Date.today }
      it { is_expected.to be_application_possible }
    end

    context 'with opening date in the future' do
      before { subject.application_opening_at = Date.today + 1 }
      it { is_expected.not_to be_application_possible }
    end

    context 'with closing date in the past' do
      before { subject.application_closing_at = Date.today - 1 }
      it { is_expected.to be_application_possible } # yep, we do not care about the closing date
    end

    context 'in other state' do
      before { subject.state = 'created' }
      it { is_expected.not_to be_application_possible }
    end

  end

  context '#advisor' do
    let(:person)  { Fabricate(:person) }
    let(:person1) { Fabricate(:person) }

    let(:event)   { Fabricate(:jubla_course, advisor_id: person.id).reload }

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
      event = Fabricate(:jubla_course, advisor_id: '')
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

  context 'application contact' do

    it 'has two possible contact groups' do
      event = Fabricate(:jubla_course, groups: [groups(:be), groups(:no)])
      expect(event.possible_contact_groups.count).to eq 2
      expect(event.valid?).to be true
    end

    it 'has one possible contact groups if the other is deleted' do
      groups(:no_agency).destroy
      event = Fabricate(:jubla_course, groups: [groups(:be), groups(:no)])
      expect(event.possible_contact_groups.count).to eq 1
      expect(event.valid?).to be true
    end

    it 'has two possible contact groups' do
      event = Fabricate(:jubla_course, groups: [groups(:no)])
      expect(event.possible_contact_groups.count).to eq 1
    end

    it 'validation fails if no contact group is assigned' do
      event = Fabricate(:jubla_course, groups: [groups(:no)])
      event.application_contact_id = nil
      expect(event.valid?).to be false
    end

    it 'validation fails if an invalid contact group is assigned' do
      event = Fabricate(:jubla_course, groups: [groups(:no)])
      event.application_contact_id = groups(:be).id
      expect(event.valid?).to be false
    end

  end

end
