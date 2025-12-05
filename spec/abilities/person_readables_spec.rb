#  Copyright (c) 2012-2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe PersonReadables do
  let(:al_schekka) { people(:al_schekka) }
  let(:user) { Fabricate(:person) }
  let(:child) { people(:child) }

  def all_accessibles(group: nil)
    group = groups(group) if group.is_a?(Symbol)
    ability = PersonReadables.new(user, group)
    Person.accessible_by(ability)
  end

  def expect_accessible(person, on_group: nil)
    expect(all_accessibles(group: on_group)).to include(person)
  end

  def expect_not_accessible(person, on_group: nil)
    expect(all_accessibles(group: on_group)).not_to include(person)
  end

  before do
    # Check our assumptions about the test people and their groups
    expect(al_schekka.groups).to include(groups(:schekka))
    expect(child.groups).to include(groups(:pegasus))
  end

  context "without group scoping" do
    it "people are not accessible" do
      expect_not_accessible(al_schekka)
      expect_not_accessible(child)
    end

    it "people are not accessible if user is creator of crisis on a different Abteilung" do
      user.crises.create!(group: groups(:chaeib))
      expect_not_accessible(al_schekka)
      expect_not_accessible(child)
    end

    it "people are accessible if user is creator of crisis on this Abteilung" do
      crises(:schekka).update(creator: user)
      expect_accessible(al_schekka)
      expect_accessible(child)
    end

    it "people are accessible if user is creator of crisis on another group of this Abteilung" do
      crises(:schekka).update(creator: user)
      expect_accessible(al_schekka)
      expect_accessible(child)
    end
  end

  context "scoped on group" do
    let(:group) { groups(:sunnewirbu) }

    it "people are not accessible" do
      expect_not_accessible(al_schekka, on_group: :schekka)
      expect_not_accessible(child, on_group: :pegasus)
    end

    it "people are not accessible if user is creator of crisis on a different Abteilung" do
      user.crises.create!(group: groups(:chaeib))

      expect(child.groups).to include(groups(:pegasus))
      expect_not_accessible(child, on_group: :pegasus)
    end

    it "people are accessible if user is creator of crisis on this Abteilung" do
      crises(:schekka).update(creator: user)

      expect_accessible(al_schekka, on_group: :schekka)
      expect_accessible(child, on_group: :pegasus)
    end

    it "people are accessible if user is creator of crisis on another group of this Abteilung" do
      crises(:schekka).update(creator: user)

      expect_accessible(al_schekka, on_group: :schekka)
      expect_accessible(child, on_group: :pegasus)
    end
  end
end
