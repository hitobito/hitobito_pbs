#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event::ListsController do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to(Time.zone.local(2015, 7, 15))
    sign_in(user)
  end

  subject { assigns(:camps).values.flatten }

  let(:yesterday) { Time.zone.now.to_date.yesterday }

  describe "GET all_camps" do
    context "as bulei" do
      let(:user) { people(:bulei) }

      before do
        now = Time.zone.now
        @current = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "closed")
        @current.dates = [Fabricate(:event_date, start_at: now - 15.days, finish_at: now - 10.days),
          Fabricate(:event_date, start_at: now - 5.days, finish_at: now + 5.days)]
        @upcoming = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "confirmed")
        @upcoming.dates = [Fabricate(:event_date, start_at: now + 10.days, finish_at: nil),
          Fabricate(:event_date, start_at: now + 12.days, finish_at: nil)]
        @upcoming2 = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "created")
        @upcoming2.dates = [Fabricate(:event_date, start_at: now + 18.days, finish_at: now + 30.days),
          Fabricate(:event_date, start_at: now + 50.days, finish_at: now + 55.days)]
        past = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: nil, state: "confirmed")
        past.dates = [Fabricate(:event_date, start_at: now - 5.days, finish_at: nil)]
        canceled = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "canceled")
        canceled.dates = [Fabricate(:event_date, start_at: now + 5.days, finish_at: nil)]
        unsubmitted = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: nil, state: "confirmed")
        unsubmitted.dates = [Fabricate(:event_date, start_at: now + 5.days, finish_at: nil)]
        future = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "confirmed")
        future.dates = [Fabricate(:event_date, start_at: now + 50.days, finish_at: nil)]
      end

      it "contains only current and upcoming camps" do
        get :all_camps
        is_expected.to eq([@current, @upcoming, @upcoming2])
      end

      it "via list_camps" do
        expect(get(:camps)).to redirect_to(list_all_camps_path)
      end
    end

    context "as abteilungsleitung" do
      let(:user) { people(:al_schekka) }

      it "is not allowed" do
        expect { get :all_camps }.to raise_error(CanCan::AccessDenied)
      end

      it "is not allowed via list_camp" do
        expect { get :camps }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "GET kantonalverband_camps" do
    context "as kantonsleitung" do
      let(:user) { Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be)).person }

      before do
        now = Time.zone.now
        @current = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "closed")
        @current.dates = [Fabricate(:event_date, start_at: now - 15.days, finish_at: now - 10.days),
          Fabricate(:event_date, start_at: now - 5.days, finish_at: now + 5.days)]
        @early = fabricate_pbs_camp(groups: [groups(:be)], camp_submitted_at: yesterday, state: "confirmed")
        @early.dates = [Fabricate(:event_date, start_at: Date.new(now.year, 3, 1), finish_at: Date.new(now.year, 3, 10))]
        @late = fabricate_pbs_camp(groups: [groups(:bern)], camp_submitted_at: yesterday, state: "confirmed")
        @late.dates = [Fabricate(:event_date, start_at: Date.new(now.year, 12, 1))]
        created = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "created")
        created.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        canceled = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "canceled")
        canceled.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        unsubmitted = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: nil, state: "confirmed")
        unsubmitted.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        future = fabricate_pbs_camp(groups: [groups(:be)], camp_submitted_at: yesterday, state: "confirmed")
        future.dates = [Fabricate(:event_date, start_at: now + 1.year, finish_at: nil)]
        other = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "confirmed")
        other.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
      end

      it "contains all camps in all subgroups this year" do
        get :kantonalverband_camps, params: {group_id: groups(:be).id}
        is_expected.to match_array([@current, @early, @late])
      end

      it "via list_camps" do
        expect(get(:camps)).to redirect_to(list_kantonalverband_camps_path(group_id: groups(:be).id))
      end
    end

    context "as bulei" do
      let(:user) { people(:bulei) }

      it "is not allowed" do
        expect { get :kantonalverband_camps, params: {group_id: groups(:be).id} }.to raise_error(CanCan::AccessDenied)
      end
    end
  end

  describe "GET camps_in_canton" do
    context "as krisenverantwortung" do
      let(:user) { Fabricate(Group::Kantonalverband::VerantwortungKrisenteam.name, group: groups(:be)).person }

      before do
        now = Time.zone.now
        groups(:be).update!(cantons: %w[be fr])

        @current = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "closed", canton: "be")
        @current.dates = [Fabricate(:event_date, start_at: now - 15.days, finish_at: now - 10.days),
          Fabricate(:event_date, start_at: now - 5.days, finish_at: now + 5.days)]
        @upcoming = fabricate_pbs_camp(groups: [groups(:chaeib)], camp_submitted_at: yesterday, state: "confirmed", canton: "be")
        @upcoming.dates = [Fabricate(:event_date, start_at: now + 18.days, finish_at: now + 30.days),
          Fabricate(:event_date, start_at: now + 50.days, finish_at: now + 55.days)]
        created = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "created", canton: "be")
        created.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        canceled = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "canceled", canton: "be")
        canceled.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        unsubmitted = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: nil, state: "confirmed", canton: "be")
        unsubmitted.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        future = fabricate_pbs_camp(groups: [groups(:be)], camp_submitted_at: yesterday, state: "confirmed", canton: "be")
        future.dates = [Fabricate(:event_date, start_at: now + 1.year, finish_at: nil)]
        other = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "confirmed", canton: "zh")
        other.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
      end

      it "contains all upcoming camps in this canton" do
        get :camps_in_canton, params: {canton: "be"}
        is_expected.to match_array([@current, @upcoming])
      end

      it "via list_camps" do
        expect(get(:camps)).to redirect_to(list_kantonalverband_camps_path(group_id: groups(:be).id))
      end
    end
  end

  describe "GET camps_abroad" do
    context "as ko int" do
      let(:user) { Fabricate(Group::Bund::InternationalCommissionerIcWagggs.name, group: groups(:bund)).person }

      before do
        now = Time.zone.now
        @current = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "closed", canton: "zz")
        @current.dates = [Fabricate(:event_date, start_at: now - 15.days, finish_at: now - 10.days),
          Fabricate(:event_date, start_at: now - 5.days, finish_at: now + 5.days)]
        @early = fabricate_pbs_camp(groups: [groups(:be)], camp_submitted_at: yesterday, state: "confirmed", canton: "zz")
        @early.dates = [Fabricate(:event_date, start_at: Date.new(now.year, 3, 1), finish_at: Date.new(now.year, 3, 10))]
        created = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "created", canton: "zz")
        created.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        canceled = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: yesterday, state: "canceled", canton: "zz")
        canceled.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        unsubmitted = fabricate_pbs_camp(groups: [groups(:schekka)], camp_submitted_at: nil, state: "confirmed", canton: "zz")
        unsubmitted.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        future = fabricate_pbs_camp(groups: [groups(:be)], camp_submitted_at: yesterday, state: "confirmed", canton: "zz")
        future.dates = [Fabricate(:event_date, start_at: now + 1.year, finish_at: nil)]
        other = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "confirmed", canton: "be")
        other.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
        empty = fabricate_pbs_camp(groups: [groups(:zh)], camp_submitted_at: yesterday, state: "confirmed")
        empty.dates = [Fabricate(:event_date, start_at: now, finish_at: nil)]
      end

      it "contains all abroad camps this year" do
        get :camps_abroad
        is_expected.to match_array([@current, @early])
      end

      it "via list_camps" do
        expect(get(:camps)).to redirect_to(list_camps_abroad_path)
      end
    end
  end

  describe "GET #bsv_export" do
    let(:rows) { response.body.delete_prefix(Export::Csv::UTF8_BOM).split("\r\n") }
    let(:user) { people(:root) }
    let(:kind) { event_kinds(:fut) }
    let(:person) do
      Fabricate(:person, street: "test_street", housenumber: "23",
        zip_code: "3128",
        town: "Foodorf",
        country: "CH")
    end

    before do
      create_course("124", "11.11.2015", "12.11.2015")
      create_course("125", "11.11.2015")
    end

    context "advanced" do
      it "includes advanced attribute labels" do
        get :bsv_export, params: {
          filter: {
            bsv_since: "09.09.2015",
            bsv_until: "08.09.2016",
            states: ["closed"],
            kinds: [kind.id]
          },
          advanced: true
        }

        labels = rows.first.split(";")
        expect(labels).to eq(["Vereinbarung-ID-FiVer",
          "Kurs-ID-FiVer",
          "Kursart",
          "Kantonalverband",
          "Regionalverband",
          "Kursnummer",
          "Start Datum",
          "End Datum",
          "Kursort",
          "Ausbildungstage",
          "BSV Tage",
          "alle berechtigten Personen (bis 30)",
          "alle berechtigten Personen (bis 30) x Tage",
          "Berechtigte Tage",
          "Leitungsteam inkl. Küche",
          "alle Personen unabhängig vom Alter",
          "alle Personen unabhängig vom Alter x Tage",
          "Total Tage",
          "Wohnkantone der TN",
          "Sprachen",
          "LKB Personen-ID",
          "LKB Vorname",
          "LKB Nachname",
          "LKB Pfadiname",
          "LKB Adresse",
          "LKB PLZ",
          "LKB Ort",
          "LKB Land",
          "LKB Email",
          "LKB Anrede"])
      end

      it "inserts values correctly" do
        get :bsv_export, params: {
          filter: {
            bsv_since: "09.09.2015",
            bsv_until: "08.09.2016",
            states: ["closed"]
          },
          advanced: true
        }
        # the first row contains the headers, data from the second row on
        values = rows.second.split(";")

        # main labels
        expect(values[0..8]).to eq(
          ["", "", "LPK (Leitpfadikurs)", "Bern, Zürich", '""', "124", "11.11.2015", "12.11.2015", ""]
        )
        # counts -> participant_, canton_ & language_count are incorrectly 0 here
        #          as person.canton is not easily setable in test here.

        expect(values[9..19]).to eq(["5", "3", "0", "", "0", "4", "6", "6x3", "18.0", "0", "0"])

        # advisor labels
        expect(values[20..29]).to eq([person.id.to_s, person.first_name, person.last_name,
          person.nickname, "test_street 23", "3128", "Foodorf", "CH",
          person.email, person.salutation_value])

        expect(values.length).to eq(30)
      end

      it "sets date_to to date from if nothing is given" do
        get :bsv_export, params: {
          filter: {
            bsv_since: "09.09.2015",
            bsv_until: "08.09.2016",
            states: ["closed"]
          },
          advanced: true
        }

        values = rows.third.split(";")
        expect(values[6]).to eq("11.11.2015")
        expect(values[7]).to eq("11.11.2015")
      end
    end

    context "access via api" do
      before do
        sign_out(user)
      end

      it "responses csv" do
        user.generate_authentication_token!

        get :bsv_export, params: {
          filter: {
            bsv_since: "09.09.2015",
            bsv_until: "08.09.2016",
            states: ["closed"]
          },
          advanced: true,
          user_token: user.authentication_token, user_email: user.email
        }

        expect(rows.length).to eq(3)
      end
    end
  end

  def fabricate_pbs_camp(overrides = {})
    if overrides[:camp_submitted_at]
      overrides = required_attrs_for_camp_submit
        .merge(overrides)
    end
    Fabricate(:pbs_camp, overrides)
  end

  def required_attrs_for_camp_submit
    {canton: "be",
     location: "foo",
     coordinates: "42",
     altitude: "1001",
     emergency_phone: "080011",
     landlord: "georg",
     coach_confirmed: true,
     lagerreglement_applied: true,
     kantonalverband_rules_applied: true,
     j_s_rules_applied: true,
     expected_participants_pio_f: 3,
     coach_id: Fabricate(:person).id,
     leader_id: Fabricate(:person).id}
  end

  def create_course(number, date_from, date_to = nil)
    course = Fabricate(:pbs_course, groups: [groups(:be), groups(:zh)],
      number: number,
      state: "closed",
      advisor_id: person.id,
      training_days: 5,
      bsv_days: 3)
    course.dates.destroy_all
    date_from = Date.parse(date_from)
    date_to = Date.parse(date_to) if date_to
    course.dates.create!(start_at: date_from, finish_at: date_to)
    create_participations(course)
  end

  def create_participations(course)
    Event::Course.role_types.each do |role|
      create_participation(course, role.name)
    end
  end

  def create_participation(course, role)
    person = Fabricate(:person, birthday: Date.new(1995, 1, 1), zip_code: 3012)
    participation = Fabricate(:pbs_participation, event: course, person: person, bsv_days: 3)
    Fabricate(role.to_sym, participation: participation)
  end
end
