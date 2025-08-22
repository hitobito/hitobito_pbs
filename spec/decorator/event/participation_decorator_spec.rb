#  Copyright (c) 2019-2025, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::ParticipationDecorator, :draper_with_helpers do
  let(:person) {
    Fabricate(:person, first_name: "John", last_name: "Doe", title: "Herr",
      nickname: nil, town: "Hitobitostadt", birthday: "2001-01-01")
  }
  let(:kind) { Fabricate(:pbs_course_kind) }
  let(:event) {
    Fabricate(:pbs_course, kind: kind, has_confirmations: true,
      location: "PBSikon", groups: [groups(:bund)])
  }
  let(:participation_roles) { [Event::Course::Role::Participant.new] }
  let(:state) { "assigned" }
  let(:qualified) { true }
  let(:participation) {
    Fabricate(:pbs_participation, state: state, participant: person, event: event,
      roles: participation_roles, qualified: qualified)
  }
  let(:decorator) { Event::ParticipationDecorator.new(participation) }

  subject { decorator }

  describe "#has_confirmation?" do
    context "returns true when all conditions met" do
      it { is_expected.to have_confirmation }
    end

    context "returns true when participant also has helper role" do
      let(:participation_roles) {
        [Event::Course::Role::Participant.new,
          Event::Course::Role::Helper.new]
      }

      it { is_expected.to have_confirmation }
    end

    context "returns false when event is not course" do
      let(:event) { Fabricate(:pbs_camp) }

      it { is_expected.not_to have_confirmation }
    end

    context "returns false when course kind does not allow confirmations" do
      let(:kind) { Fabricate(:pbs_course_kind, can_have_confirmations: false) }

      it { is_expected.not_to have_confirmation }
    end

    context "returns false when course does not allow confirmations" do
      let(:event) { Fabricate(:course, kind: kind, has_confirmations: false) }

      it { is_expected.not_to have_confirmation }
    end

    context "returns false when participation is not a participant" do
      let(:participation_roles) { [Event::Course::Role::Helper.new] }

      it { is_expected.not_to have_confirmation }
    end

    context "returns false when participation is not active" do
      let(:state) { "applied" }

      it { is_expected.not_to have_confirmation }
    end

    context "returns false when participant is not qualified" do
      let(:qualified) { false }

      it { is_expected.not_to have_confirmation }
    end
  end

  describe "#course_confirmation_params" do
    it "has assumptions" do
      expect(decorator.event.dates).to be_present
      expect(decorator.event.dates).to have(1).item
      expect(decorator.event.dates.first.duration).to be_a Duration
      expect(decorator.event.dates.first.duration.instance_variable_get(:@date_format)).to eql :default

      # result
      expect(decorator.send(:course_confirmation_params).fetch(:dauer)).to eql("11.05.2012")
    end

    it "returns the correct parameters" do
      expect(decorator.send(:course_confirmation_params))
        .to eq({name: "Doe",
                vorname: "John",
                anrede: "Herr",
                wohnort: "Hitobitostadt",
                geburtstag: "01.01.2001",
                kursOrt: "PBSikon",
                dauer: "11.05.2012",
                organisator: "Pfadibewegung Schweiz"})
    end

    it "can handle empty fields" do
      decorator.person.update(first_name: nil, last_name: nil, title: nil, town: nil, birthday: nil)
      decorator.event.update(location: nil)
      decorator.event.dates.delete_all
      expect(decorator.send(:course_confirmation_params))
        .to eq({name: nil,
                 vorname: nil,
                 anrede: nil,
                 wohnort: nil,
                 geburtstag: nil,
                 kursOrt: nil,
                 dauer: "",
                 organisator: "Pfadibewegung Schweiz"})
    end
  end

  context "#course_confirmation_form" do
    include Haml::Helpers

    subject { decorator.course_confirmation_form { "submit button" } }

    before do
      event.update(location: "Line 1\nLine 2")
      kind.update(can_have_confirmations: true)
      participation.update(qualified: true)
    end

    it "multiline values in hidden fields are escaped and not indented" do
      is_expected.to match(/value="Line 1\nLine 2"/)
    end
  end
end
