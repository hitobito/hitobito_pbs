# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Participation do

  let(:event) { Fabricate(:event, groups: [groups(:be)]) }
  let(:person) { people(:al_schekka) }

  describe '#state' do
    let(:event) { Fabricate(:course, groups: [groups(:be)], kind: event_kinds(:lpk)) }

    it 'does not allow nil state' do
      p = Event::Participation.new(event: event, person: person, state: nil)
      expect(p).to_not be_valid
    end

    it 'does not allow "foo" state' do
      p = Event::Participation.new(event: event, person: person, state: 'foo')
      expect(p).to_not be_valid
    end

    %w(tentative applied assigned rejected canceled attended absent).each do |state|
      it "allows \"#{state}\" state" do
        p = Event::Participation.new(event: event, person: person, state: state)
        expect(p).to be_valid
      end
    end
  end

end
