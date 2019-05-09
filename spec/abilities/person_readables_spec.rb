# encoding: utf-8

#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PersonReadables do

  let(:ability)        { PersonReadables.new(crisis_creator) }
  let(:crisis_creator) { Fabricate(:person) }
  let(:member)         { roles(:al_schekka).person }

  subject { Person.accessible_by(ability) }

  it 'member is not accessible' do
    expect(subject).not_to include(member)
  end

  it 'member is acessible if person created crisis on group' do
    crises(:al_schekka_be).update(creator: crisis_creator)
    expect(subject).to include(member)
  end

  it 'member is acessible if person created crisis above layer' do
    crises(:bulei_bund).update(creator: crisis_creator)
    expect(subject).to include(member)
  end

  it 'member is not acessible if person created crisis in sibling' do
    crisis_creator.crises.create!(group: groups(:schweizerstern))
    expect(subject).not_to include(member)
  end
end
