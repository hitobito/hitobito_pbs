# encoding: utf-8

#  Copyright (c) 2012-2020, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Export::Tabular::Events::Row do


  context :course do
    let(:event) { events(:top_course) }

    describe Event::Course::Role::Leader do
      it 'is marked as leader' do
        expect(subject.kind).to eq :leader
        expect(subject.class).to be_leader
      end
    end

    describe :row do
      let(:row) { Export::Tabular::Events::Row.new(event, :format, :state_counts, :gender_counts) }
      subject { row.fetch(:leader_name) }

      it 'includes Event::Camp::Role::Leader although role kind is nil' do
        expect(subject).to eq "Dr. Bundes Leiter / Scout"
      end

      it 'returns other leaders even if leader participations exists' do
        event_participations(:top_leader).destroy!
        participation = Fabricate(:event_participation, event: event)
        role = Fabricate(Event::Course::Role::Helper.name.to_sym, participation: participation)
        expect(role.class).to be_leader
        expect(subject).not_to be_nil
      end
    end
  end


  context :camp do
    let(:event) { events(:schekka_camp) }
    describe Event::Camp::Role::Leader do
      it 'is not marked as leader' do
        expect(subject.kind).to be_nil
        expect(subject.class).not_to be_leader
      end
    end

    describe :row do
      let(:row) { Export::Tabular::Events::Row.new(event, :format, :state_counts, :gender_counts) }
      subject { row.fetch(:leader_name) }

      it 'includes Event::Camp::Role::Leader although role kind is nil' do
        expect(subject).to eq "Dr. Bundes Leiter / Scout"
      end

      it 'returns nil even if other Leader Participations exists' do
        event_participations(:schekka_camp_leader).destroy!
        participation = Fabricate(:event_participation, event: event)
        role = Fabricate(Event::Camp::Role::AssistantLeader.name.to_sym, participation: participation)
        expect(role.class).to be_leader
        expect(subject).to be_nil
      end
    end
  end

end
