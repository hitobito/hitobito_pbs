#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe PersonReadables do
  let(:ability) { PersonReadables.new(crisis_creator) }
  let(:al_schekka) { people(:al_schekka) }
  let(:child) { people(:child) }
  let(:crisis_creator) { Fabricate(:person) }

  subject { Person.accessible_by(ability) }

  it "people are not accessible" do
    expect(subject).not_to include(al_schekka)
    expect(subject).not_to include(child)
  end

  it "people are not accessible if person is creator of crisis on a different Abteilung" do
    crisis_creator.crises.create!(group: groups(:chaeib))
    expect(subject).not_to include(al_schekka)
    expect(subject).not_to include(child)
  end

  it "people are accessible if person is creator of crisis on this Abteilung" do
    crises(:schekka).update(creator: crisis_creator)
    expect(subject).to include(al_schekka)
    expect(subject).to include(child)
  end
end
