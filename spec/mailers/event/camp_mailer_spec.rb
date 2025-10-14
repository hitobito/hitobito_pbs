#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::CampMailer do
  let(:camp) {
    Fabricate(:pbs_camp, groups: [groups(:sunnewirbu)], name: "Wirbelcamp")
  }
  let(:camp_url) { group_event_url(camp.groups.first, camp) }
  let(:recipient) { people(:al_schekka) }
  let(:recipients) { [people(:al_schekka)] }
  let(:actuator) do
    actuator = Fabricate(Group::Woelfe::Einheitsleitung.name.to_sym,
      group: groups(:sunnewirbu)).person
    actuator.update(first_name: "Wirbel", last_name: "Sturm")
    actuator
  end
  let(:actuator_id) { actuator.id }
  let(:coach) do
    coach = Fabricate(Group::Woelfe::Wolf.name.to_sym, group: groups(:sunnewirbu)).person
    coach.update(first_name: "Heftige", last_name: "Boe")
    coach
  end
  let(:abteilungsleitung) {
    Fabricate(Group::Woelfe::Wolf.name.to_sym, group: groups(:sunnewirbu)).person
  }
  let(:other_person) do
    other_person = Fabricate(Group::Woelfe::Wolf.name.to_sym,
      group: groups(:sunnewirbu)).person
    other_person.update(first_name: "Wind", last_name: "Hose")
    other_person
  end
  let!(:leader) do
    role = Fabricate(:event_role, type: Event::Camp::Role::Leader.sti_name)
    Fabricate(:pbs_participation, event: camp, roles: [role], active: true).person
  end
  let(:participation) { Fabricate(:pbs_participation, participant: other_person, event: camp) }

  before do
    camp.update(coach_id: coach.id)
    camp.update(abteilungsleitung_id: abteilungsleitung.id)
  end

  describe "#camp_created" do
    let(:mail) { Event::CampMailer.camp_created(camp, recipients, actuator.id) }

    context "headers" do
      subject { mail }

      its(:subject) { is_expected.to eq "Lager wurde erstellt" }
      its(:to) { is_expected.to eq ["al.schekka@hitobito.example.com"] }
      its(:from) { is_expected.to eq ["noreply@localhost"] }
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        is_expected.to match(/Das Lager "Wirbelcamp" wurde von Wirbel Sturm.*erstellt/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe "#advisor_assigned" do
    context "coach" do
      let(:mail) { Event::CampMailer.advisor_assigned(camp, coach, "coach", actuator_id) }

      context "headers" do
        subject { mail }

        its(:subject) { is_expected.to eq "Lager: Coach zugeordnet" }
        its(:to) { is_expected.to eq [coach.email] }
        its(:from) { is_expected.to eq ["noreply@localhost"] }
      end

      context "body" do
        subject { mail.body }

        it "renders placeholders" do
          # rubocop:todo Layout/LineLength
          is_expected.to match(/Wirbel Sturm.*hat im Lager "Wirbelcamp" Heftige Boe.*als Coach definiert/)
          # rubocop:enable Layout/LineLength
          is_expected.to match(camp_url)
        end
      end
    end

    context "advisor" do
      let(:mail) {
        Event::CampMailer.advisor_assigned(camp, other_person, "advisor_mountain_security",
          actuator_id)
      }

      context "headers" do
        subject { mail }

        its(:subject) { is_expected.to eq "Lager: Sicherheitsbereich Betreuung zugeordnet" }
        its(:to) { is_expected.to eq [other_person.email] }
        its(:from) { is_expected.to eq ["noreply@localhost"] }
      end

      context "body" do
        subject { mail.body }

        it "renders placeholders" do
          # rubocop:todo Layout/LineLength
          is_expected.to match(/Wirbel Sturm.* hat im Lager "Wirbelcamp" Wind Hose.*als Sicherheitsbereich Betreuung definiert/)
          # rubocop:enable Layout/LineLength
          is_expected.to match(camp_url)
        end
      end
    end

    context "abteilungsleitung" do
      let(:mail) {
        Event::CampMailer.advisor_assigned(camp, other_person, "abteilungsleitung", actuator_id)
      }

      context "headers" do
        subject { mail }

        its(:subject) { is_expected.to eq "Lager: Abteilungsleitung zugeordnet" }
        its(:to) { is_expected.to eq [other_person.email] }
        its(:from) { is_expected.to eq ["noreply@localhost"] }
      end

      context "body" do
        subject { mail.body }

        it "renders placeholders" do
          # rubocop:todo Layout/LineLength
          is_expected.to match(/Wirbel Sturm.*hat im Lager "Wirbelcamp" Wind Hose.*als Abteilungsleitung definiert/)
          # rubocop:enable Layout/LineLength
          is_expected.to match(camp_url)
        end
      end
    end
  end

  describe "#remind" do
    let(:mail) { Event::CampMailer.remind(camp, recipient) }

    context "headers" do
      subject { mail }

      its(:subject) { is_expected.to eq "Lager: Lager einreichen Erinnerung" }
      its(:to) { is_expected.to eq ["al.schekka@hitobito.example.com"] }
      its(:from) { is_expected.to eq ["noreply@localhost"] }
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        is_expected.to match(/Das Lager "Wirbelcamp" muss noch an PBS eingereicht werden/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe "#submit_camp" do
    let(:mail) { Event::CampMailer.submit_camp(camp) }

    context "headers" do
      context "domestic" do
        subject { mail }

        its(:subject) { is_expected.to eq "Einreichung Lager" }
        its(:to) { is_expected.to eq ["lager@pbs.ch"] }
        its(:cc) { is_expected.to match_array [coach.email, abteilungsleitung.email, leader.email] }
        its(:from) { is_expected.to eq ["noreply@localhost"] }
      end

      context "foreign" do
        before { camp.update(canton: "zz") }

        subject { mail }

        its(:subject) { is_expected.to eq "Einreichung Lager" }
        its(:to) { is_expected.to eq ["lager@pbs.ch", "auslandlager@pbs.ch"] }
        its(:cc) { is_expected.to match_array [coach.email, abteilungsleitung.email, leader.email] }
        its(:from) { is_expected.to eq ["noreply@localhost"] }
      end
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        # rubocop:todo Layout/LineLength
        is_expected.to match(/Heftige Boe.*reicht das Lager "Wirbelcamp" ein.*PDF:.*http.*\/camp_application/)
        # rubocop:enable Layout/LineLength
        is_expected.to match(camp_url)
      end
    end
  end

  describe "#participant_applied_info" do
    let(:mail) { Event::CampMailer.participant_applied_info(participation, recipients) }

    context "headers" do
      subject { mail }

      its(:subject) { is_expected.to eq "Lager: Teilnehmer-/in hat sich angemeldet" }
      its(:to) { is_expected.to eq ["al.schekka@hitobito.example.com"] }
      its(:from) { is_expected.to eq ["noreply@localhost"] }
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        is_expected.to match(/Wind Hose.*hat sich für das Lager "Wirbelcamp" angemeldet/)
        is_expected.to match(camp_url)
      end
    end
  end

  describe "#participant_canceled_info" do
    let(:mail) { Event::CampMailer.participant_canceled_info(participation, recipients) }

    context "headers" do
      subject { mail }

      its(:subject) { is_expected.to eq "Lager: Teilnehmer-/in hat sich abgemeldet" }
      its(:to) { is_expected.to eq ["al.schekka@hitobito.example.com"] }
      its(:from) { is_expected.to eq ["noreply@localhost"] }
    end

    context "body" do
      subject { mail.body }

      it "renders placeholders" do
        is_expected.to match(/Wind Hose.*hat sich vom Lager "Wirbelcamp" abgemeldet/)
        is_expected.to match(camp_url)
      end
    end
  end
end
