# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::RestrictedRole do

  let(:person)  { Fabricate(:person) }
  let(:person1) { Fabricate(:person) }

  let(:event)   { Fabricate(:pbs_camp, abteilungsleitung_id: person.id).reload }

  subject { event }

  its(:abteilungsleitung) { should == person }
  its(:abteilungsleitung_id) { should == person.id }

  it "shouldn't change the al if the same is already set" do
    subject.abteilungsleitung_id = person.id
    expect { subject.save! }.not_to change { Event::Role.count }
    expect(subject.abteilungsleitung).to eq person
  end

  it 'should update the abteilungsleitung if another person is assigned' do
    event.abteilungsleitung_id = person1.id
    expect(event.save).to be_truthy
    expect(event.abteilungsleitung).to eq person1
  end

  it "shouldn't try to add abteilungsleitung if id is empty" do
    event = Fabricate(:pbs_camp, abteilungsleitung_id: '')
    expect(event.abteilungsleitung).to be nil
  end

  it 'removes existing abteilungsleitung if id is set blank' do
    subject.abteilungsleitung_id = person.id
    subject.save!

    subject.abteilungsleitung_id = ''
    expect { subject.save! }.to change { Event::Role.count }.by(-1)
  end

  it 'removes existing abteilungsleitung participation if id is set blank' do
    subject.abteilungsleitung_id = person.id
    subject.save!

    subject.abteilungsleitung_id = ''

    expect do
      expect do
        subject.save!
      end.to change { Event::Participation.count }.by(-1)
    end.to change { Event::Role.count }.by(-1)
  end

  it 'keeps existing abteilungsleitung participation if id is set blank and other roles exist' do
    subject.abteilungsleitung_id = person.id
    subject.save!

    Fabricate(Event::Camp::Role::Helper.name, participation: person.event_participations.first)

    subject.abteilungsleitung_id = ''
    expect do
      expect do
        subject.save!
      end.not_to change { Event::Participation.count }
    end.to change { Event::Role.count }.by(-1)
  end

  it 'removes existing and creates new abteilungsleitung on reassignment' do
    subject.abteilungsleitung_id = person.id
    subject.save!

    new_al = Fabricate(:person)
    subject.abteilungsleitung_id = new_al.id
    expect { subject.save! }.not_to change { Event::Role.count }
    expect(Event.find(subject.id).abteilungsleitung_id).to eq(new_al.id)
    expect(subject.participations.where(person_id: person.id)).not_to be_exists
  end

  it 'adds answers to new participation' do
    event.update!(abteilungsleitung_id: '')
    Fabricate(:event_question, event: event)
    event.reload

    subject.abteilungsleitung_id = person.id
    expect { subject.save! }.to change { Event::Answer.count }.by(1)
  end

  it 'does not add answers to existing participation' do
    event.update!(abteilungsleitung_id: '')
    Fabricate(:event_question, event: event)
    event.reload
    p = Fabricate(:event_participation, event: event, person: person)
    p.init_answers
    p.save!
    Fabricate(Event::Camp::Role::Helper.name, participation: p)

    subject.abteilungsleitung_id = person.id
    expect do
      expect do
        expect do
          subject.save!
        end.to change { Event::Role.count }.by(1)
      end.not_to change { Event::Participation.count }
    end.not_to change { Event::Answer.count }
  end

end
