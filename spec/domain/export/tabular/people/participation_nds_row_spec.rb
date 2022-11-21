# frozen_string_literal: true

# Copyright (c) 2012-2022, Pfadibewegung Schweiz. This file is part of
# hitobito_pbs and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Export::Tabular::People::ParticipationNdsRow do

  let(:participation) { Fabricate(:event_participation, person: person, event: events(:top_course)) }

  let(:row) { described_class.new(participation) }

  context 'with correspondence language' do
    let(:person) { Fabricate(:person, correspondence_language: 'it') }
    it { expect(row.fetch(:first_language)).to eq 'IT' }
  end

  context 'without correspondence language' do
    let(:person) { Fabricate(:person, correspondence_language: nil) }
    it { expect(row.fetch(:first_language)).to eq 'DE' }
  end
end
