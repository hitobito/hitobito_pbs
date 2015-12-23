# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Participation do
  let(:event) { events(:top_course) }

  context '#approvers' do
    it 'is empty if no application exists' do
      expect(Fabricate(:pbs_participation, event: event).approvers).to be_empty
    end

    it 'returns people that approved or rejected participation' do
      participation = Fabricate(:pbs_participation, event: event, application: Event::Application.new(priority_1: event))
      participation.application.approvals.create!(layer: 'abteilung', approved: true, approver: people(:al_schekka))
      participation.application.approvals.create!(layer: 'region', rejected: true, approver: people(:bulei))
      participation.application.approvals.create!(layer: 'kantonalverband')

      expect(participation.approvers).to have(2).items
      expect(participation.approvers).to include(people(:bulei), people(:al_schekka))
    end
  end

  context 'verifying participatable counts' do

    before { event.refresh_participant_counts! } # to create existing participatiots

    def create_participant(state)
      participation = Fabricate(:pbs_participation, event: event, state: state, canceled_at: Date.today)
      participation.roles.create!(type: event.class.participant_types.first.name)
    end

    context 'simple' do
      let(:event) { events(:top_event) }

      it "creating application does increase event#application_count" do
        expect { create_participant(nil) }.to change { event.reload.applicant_count }.by(1)
      end
    end

    context 'course' do
      %w(tentative canceled rejected).each do |state|
        it "creating #{state} application does not increase event#applicant_count" do
          expect { create_participant(state) }.not_to change { event.reload.applicant_count }
        end
      end

      %w(applied assigned attended absent).each do |state|
        it "creating #{state} application does increase event#application_count" do
          expect { create_participant(state) }.to change { event.reload.applicant_count }.by(1)
        end
      end
    end

    context 'camp' do
      let(:event) { events(:schekka_camp) }

      %w(canceled).each do |state|
        it "creating #{state} application does not increase event#applicant_count" do
          expect { create_participant(state) }.not_to change { event.reload.applicant_count }
        end
      end

      %w(applied_electronically assigned absent).each do |state|
        it "creating #{state} application does increase event#application_count" do
          expect { create_participant(state) }.to change { event.reload.applicant_count }.by(1)
        end
      end

      it 'assigns participant directly if no paper application required' do
        p = Event::Participation.new(event: event, person: Fabricate(:person))
        p.roles.build(type: Event::Camp::Role::Participant.sti_name)
        p.save!
        expect(p.state).to eq('assigned')
      end

      it 'assigns leader directly if paper application required' do
        event.update!(paper_application_required: true)
        p = Event::Participation.new(event: event, person: Fabricate(:person))
        p.roles.build(type: Event::Camp::Role::Helper.sti_name)
        p.save!
        expect(p.state).to eq('assigned')
      end

      it 'set participant applied_electronically if paper application required' do
        event.update!(paper_application_required: true)
        p = Event::Participation.new(event: event, person: Fabricate(:person))
        p.roles.build(type: Event::Camp::Role::Participant.sti_name)
        p.save!
        expect(p.state).to eq('applied_electronically')
      end
    end

  end

end
