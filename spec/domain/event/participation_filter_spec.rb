# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationFilter do

  let(:event) { events(:top_course) }
  let(:user) { people(:bulei) }
  let(:filter) { Event::ParticipationFilter.new(event, user, filter: tab)}
  let(:tab) { nil }

  before do
    @canceled = create_participant(state: 'canceled', canceled_at: Date.today)
    @absent = create_participant(state: 'absent')
    @tentative = create_participant(state: 'tentative')
    @applied = create_participant(state: 'applied')
    @leader = event_participations(:top_leader)
    @assigned = event_participations(:top_participant)
  end

  context 'predefined_filters' do
    context 'for course' do
      it 'contains revoked' do
        expect(filter.predefined_filters).to include('revoked')
      end
    end

    context 'for simple events' do
      let(:event) { events(:top_event) }

      it 'does not contain revoked' do
        expect(filter.predefined_filters).not_to include('revoked')
      end
    end

    context 'for course participant' do
      let(:user) { people(:al_schekka) }

      it 'does not contain revoked' do
        expect(filter.predefined_filters).not_to include('revoked')
      end
    end
  end

  context 'revoked' do
    let(:tab) { 'revoked' }

    it 'lists all revoked entries' do
      expect(filter.list_entries).to match_array([@canceled, @absent])
      expect(filter.counts).to eq('all' => 2, 'teamers' => 1, 'participants' => 1, 'revoked' => 2)
    end
  end

  context 'all' do
    let(:tab) { 'all' }

    it 'lists only active entries' do
      expect(filter.list_entries).to match_array([@assigned, @leader])
      expect(filter.counts).to eq('all' => 2, 'teamers' => 1, 'participants' => 1, 'revoked' => 2)
    end
  end

  context 'participants' do
    let(:tab) { 'participants' }

    it 'lists only active entries' do
      expect(filter.list_entries).to match_array([@assigned])
      expect(filter.counts).to eq('all' => 2, 'teamers' => 1, 'participants' => 1, 'revoked' => 2)
    end
  end

  def create_participant(attrs)
    Fabricate(:event_participation,
              attrs.merge(
                event: event,
                roles: [Fabricate(Event::Course::Role::Participant.name.to_sym)]))
  end

end
