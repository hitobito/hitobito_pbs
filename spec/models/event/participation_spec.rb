# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Participation do
  let(:course) { events(:top_course) }

  describe '#state' do
    let(:event) { Fabricate(:course, groups: [groups(:be)], kind: event_kinds(:lpk)) }
    let(:person) { people(:al_schekka) }

    it 'sets default state' do
      p = Event::Participation.new(event: event, person: person, state: nil)
      expect(p).to be_valid
      expect(p.state).to eq 'applied'
    end

    it 'does not allow "foo" state' do
      p = Event::Participation.new(event: event, person: person, state: 'foo')
      expect(p).to_not be_valid
    end

    %w(tentative applied assigned rejected canceled attended absent).each do |state|
      it "allows \"#{state}\" state" do
        p = Event::Participation.new(event: event, person: person, state: state, canceled_at: Date.today)
        expect(p).to be_valid
      end
    end
  end

  context 'destroying tentative_applications' do
    let(:participation) { event_participations(:top_participant) }

    before { participation.update!(state: 'tentative', active: false) }

    it "applying for that course deletes tentative participation" do
      expect do
        Fabricate(:pbs_participation, event: course, person: participation.person)
      end.not_to change { Event::Participation.count }
      expect { participation.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "applying for that course kind deletes tentative participation" do
      other_course = Fabricate(:pbs_course, groups: [groups(:zh)])
      expect do
        Fabricate(:pbs_participation, event: other_course, person: participation.person)
      end.not_to change { Event::Participation.count }
      expect { participation.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it "applying for different course kind does not delete tentative participation" do
      other_course = Fabricate(:pbs_course, kind: event_kinds(:bkws), groups: [groups(:zh)])
      expect do
        Fabricate(:pbs_participation, event: other_course, person: participation.person)
      end.to change { Event::Participation.count }.by(1)
      expect { participation.reload }.not_to raise_error
    end

    it "applying with invalid state does not delete tentative participation" do
      Event::Participation.create(event: course, person: participation.person, state: 'invalid')
      expect { participation.reload }.not_to raise_error
    end
  end


  context 'verifying participatable counts' do
    before { course.refresh_participant_counts! } # to create existing participatiots

    def create_participant(state)
      participation = Fabricate(:pbs_participation, event: course, state: state, canceled_at: Date.today)
      participation.roles.create!(type: Event::Course::Role::Participant.name)
    end

    %w(tentative canceled rejected).each do |state|
      it "creating #{state} application does not increase course#applicant_count" do
        expect { create_participant(state) }.not_to change { course.reload.applicant_count }
      end
    end

    %w(applied assigned attended absent).each do |state|
      it "creating #{state} application does increase course#application_count" do
        expect { create_participant(state) }.to change { course.reload.applicant_count }.by(1)
      end
    end
  end

end
