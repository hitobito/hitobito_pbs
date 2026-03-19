#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Events::CoursesController do
  include ActiveSupport::Testing::TimeHelpers

  before do
    travel_to(Time.zone.local(2015, 7, 15))
    sign_in(user)
  end

  subject { assigns(:camps).values.flatten }

  let(:yesterday) { Time.zone.now.to_date.yesterday }

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
          filters: {
            bsv_date_range: {since: "09.09.2015", until: "08.09.2016"},
            state: {states: ["closed"]},
            bsv_kind: {ids: [kind.id]}
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
          filters: {
            bsv_date_range: {since: "09.09.2015", until: "08.09.2016"},
            state: {states: ["closed"]}
          },
          advanced: true
        }
        # the first row contains the headers, data from the second row on
        values = rows.second.split(";")

        # main labels
        expect(values[0..8]).to eq(
          ["", "", "LPK (Leitpfadikurs)", "Bern, Zürich", '""', "124", "11.11.2015", "12.11.2015",
            ""]
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
          filters: {
            bsv_date_range: {since: "09.09.2015", until: "08.09.2016"},
            state: {states: ["closed"]}
          },
          advanced: true
        }

        values = rows.third.split(";")
        expect(values[6]).to eq("11.11.2015")
        expect(values[7]).to eq("11.11.2015")
      end
    end
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
    participation = Fabricate(:pbs_participation, event: course, participant: person, bsv_days: 3)
    Fabricate(role.to_sym, participation: participation)
  end
end
