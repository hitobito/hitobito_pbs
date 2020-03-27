# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Export::Tabular::People::ParticipationNdbjsRow do

  let(:person) { Fabricate(:person, correspondence_language: 'it') }
  let(:participation) { Fabricate(:event_participation, person: person, event: events(:top_course)) }

  let(:row) { Export::Tabular::People::ParticipationNdbjsRow.new(participation) }

  it { expect(row.fetch(:first_language)).to eq 'I' }

end
