# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationDecorator, :draper_with_helpers do

  let(:person) { Fabricate(:person, first_name: 'John', last_name: 'Doe', nickname: nil) }
  let(:state) { 'applied' }
  let(:participation) { Event::Participation.new(state: state, person: person) }
  let(:decorator) { Event::ParticipationDecorator.new(participation) }

  describe '#state_translated' do

    { tentative: 'Provisorisch',
      applied: 'Angemeldet',
      assigned: 'Zugeteilt',
      rejected: 'Abgelehnt',
      canceled: 'Abgemeldet',
      attended: 'Teilgenommen',
      absent: 'Nicht erschienen' }.each do |state, translation|
      context "state #{state}" do
        let(:state) { state.to_s }

        it 'returns the translation string' do
          expect(decorator.state_translated).to eq(translation)
        end
      end
    end
  end

  describe '#to_s' do
    %w(tentative applied assiged attended).each do |state|
      context "state #{state}" do
        let(:state) { state.to_s }

        it 'does not append state' do
          expect(decorator.to_s).to eq('John Doe')
        end
      end
    end

    { rejected: 'Abgelehnt',
      canceled: 'Abgemeldet',
      absent: 'Nicht erschienen' }.each do |state, translation|
      context "state #{state}" do
        let(:state) { state.to_s }

        it 'appends translated state name' do
          expect(decorator.to_s).to eq("John Doe (#{translation})")
        end
      end
    end
  end

end
