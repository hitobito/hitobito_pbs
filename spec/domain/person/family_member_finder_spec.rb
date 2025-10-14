#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Person::FamilyMemberFinder do
  let(:service) { described_class.new(person) }
  let(:person) { Fabricate(:person) }
  let(:sibling) { Fabricate(:person) }

  let!(:sibling_relation) {
    Fabricate(:family_member, person: person, other: sibling, kind: :sibling)
  }

  describe "#family_members_in_event" do
    let(:person_event) { Fabricate(:event) }
    let!(:person_participation) {
      Fabricate(:event_participation, participant: person, event: person_event)
    }
    let(:sibling_event) { Fabricate(:event) }
    let!(:sibling_participation) {
      Fabricate(:event_participation, participant: sibling, event: sibling_event)
    }

    subject do
      service.family_members_in_event(person_event, kind: :sibling)
    end

    context "without siblings" do
      let!(:sibling_relation) { nil }

      it { is_expected.to be_empty }
    end

    context "with siblings in different events" do
      it { is_expected.to be_empty }
    end

    context "with siblings in same event" do
      let(:sibling_event) { person_event }

      it { is_expected.to contain_exactly(sibling_participation.participant) }
    end

    context "with siblings with deleted role in same group" do
      let!(:sibling_participation) {
        Fabricate(:event_participation, participant: sibling, event: sibling_event, active: false)
      }

      it { is_expected.to be_empty }
    end
  end

  describe "#family_members_in_layer" do
    let(:layer) { Fabricate(Group::Abteilung.name) }

    let(:person_group) { Fabricate(Group::Pfadi.name, parent: layer) }
    let!(:person_role) {
      Fabricate(person_group.standard_role.name, person: person, group: person_group)
    }

    let(:sibling_group) { Fabricate(Group::Woelfe.name, parent: layer) }
    let!(:sibling_role) {
      Fabricate(sibling_group.standard_role.name, person: sibling, group: sibling_group)
    }

    subject do
      service.family_members_in_layer(person_group, kind: :sibling)
    end

    context "without siblings" do
      let!(:sibling_relation) { nil }

      it { is_expected.to be_empty }
    end

    context "with siblings in different groups" do
      let(:sibling_group) {
        Fabricate(Group::Woelfe.name, parent: Fabricate(Group::Abteilung.name))
      }

      it { is_expected.to be_empty }
    end

    context "with siblings in same group" do
      let(:sibling_group) { person_group }

      it { is_expected.to contain_exactly(sibling_role.person) }
    end

    context "with siblings in same layer" do
      it { is_expected.to contain_exactly(sibling_role.person) }
    end

    context "with siblings with deleted role in same group" do
      let!(:sibling_role) do
        Fabricate(sibling_group.standard_role.name, person: sibling, group: sibling_group,
          created_at: 2.months.ago, end_on: 1.month.ago)
      end

      it { is_expected.to be_empty }
    end
  end
end
