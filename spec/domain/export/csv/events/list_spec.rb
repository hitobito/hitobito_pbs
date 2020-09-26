# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require 'csv'

describe Export::Tabular::Events::List do

  let(:courses) { double('courses', map: [], first: nil) }
  let(:list)  { Export::Tabular::Events::List.new(courses) }
  subject { list }

  context 'used labels' do
    subject { list }

    its(:attributes) do
      should == [:name, :group_names, :number, :kind, :description, :state, :location,
                 :date_0_label, :date_0_location, :date_0_duration,
                 :date_1_label, :date_1_location, :date_1_duration,
                 :date_2_label, :date_2_location, :date_2_duration,
                 :contact_name, :contact_address, :contact_zip_code, :contact_town,
                 :contact_email, :contact_phone_numbers,
                 :leader_name, :leader_address, :leader_zip_code, :leader_town,
                 :leader_email, :leader_phone_numbers,
                 :advisor_name, :advisor_address, :advisor_zip_code, :advisor_town,
                 :advisor_email, :advisor_phone_numbers,
                 :motto, :cost, :application_opening_at, :application_closing_at,
                 :maximum_participants, :external_applications, :priorization, :training_days,
                 :express_fee, :language_de, :language_fr, :language_it, :language_en,
                 :teamer_count, :participant_count, :applicant_count,
                 :male_count, :female_count, :canceled_count, :absent_count, :rejected_count]
    end

    its(:labels) do
      should == ['Name', 'Organisatoren', 'Kursnummer', 'Kursart', 'Beschreibung', 'Status', 'Ort / Adresse',
                 'Datum 1 Bezeichnung', 'Datum 1 Ort', 'Datum 1 Zeitraum',
                 'Datum 2 Bezeichnung', 'Datum 2 Ort', 'Datum 2 Zeitraum',
                 'Datum 3 Bezeichnung', 'Datum 3 Ort', 'Datum 3 Zeitraum',
                 'Kontaktperson Name', 'Kontaktperson Adresse', 'Kontaktperson PLZ',
                 'Kontaktperson Ort', 'Kontaktperson Haupt-E-Mail', 'Kontaktperson Telefonnummern',
                 'Hauptleitung Name', 'Hauptleitung Adresse', 'Hauptleitung PLZ', 'Hauptleitung Ort',
                 'Hauptleitung Haupt-E-Mail', 'Hauptleitung Telefonnummern',
                 'LKB Name', 'LKB Adresse', 'LKB PLZ', 'LKB Ort',
                 'LKB Haupt-E-Mail', 'LKB Telefonnummern',
                 'Motto', 'Kosten', 'Anmeldebeginn', 'Anmeldeschluss', 'Maximale Teilnehmerzahl',
                 'Externe Anmeldungen', 'Priorisierung', 'Ausbildungstage', 'Expressgebühr',
                 'Kurssprache Deutsch', 'Kurssprache Französisch', 'Kurssprache Italienisch',
                 'Kurssprache Englisch', 'Anzahl Leitungsteam', 'Anzahl Teilnehmende',
                 'Anzahl Anmeldungen', 'Anzahl Teilnehmende Männer', 'Anzahl Teilnehmende Frauen',
                 'Anzahl Abgemeldete', 'Anzahl Nicht erschienene', 'Anzahl Abgelehnte']
    end
  end


  context 'to_csv' do
    let(:courses) { Event::Course.where(id: course) }
    let(:course) do
      Fabricate(:pbs_course,
                groups: [groups(:be)],
                location: 'somewhere',
                state: 'completed',
                training_days: 7,
                express_fee: 'yada 500',
                language_de: true,
                language_fr: false,
                language_it: true,
                advisor_id: people(:bulei).id)
    end
    let(:csv) { Export::Csv::Generator.new(list).call.split("\n")  }

    context 'headers' do
      subject { csv.first }
      it { is_expected.to match(/^Name;Organisatoren;Kursnummer;Kursart;.*;LKB Name;.*;Anzahl Abgelehnte$/) }
    end

    context 'first row' do
      subject { csv.second.split(';') }
      its([1]) { is_expected.to eq 'Bern' }
      its([5]) { is_expected.to eq 'Qualifikationen erfasst' }
      its([6]) { is_expected.to eq 'somewhere' }
      its([28]) { is_expected.to eq 'Dr. Bundes Leiter / Scout' } # advisor name
      its([41]) { is_expected.to eq '7.0' } # training_days
      its([42]) { is_expected.to eq 'yada 500' } # express fee
      its([43]) { is_expected.to eq 'ja' }   # de
      its([44]) { is_expected.to eq 'nein' } # fr
      its([45]) { is_expected.to eq 'ja' }   # it
      its([46]) { is_expected.to eq 'nein' } # en
    end

    context 'without advisor' do
      let(:course) do
        Fabricate(:pbs_course,
                  groups: [groups(:be)],
                  location: 'somewhere',
                  state: 'completed',
                  training_days: 7,
                  express_fee: 'yada 500',
                  language_de: true,
                  language_fr: false,
                  language_it: true)
      end

      subject { csv.second.split(';') }

      its([28]) { is_expected.to eq '' } # advisor name
      its([29]) { is_expected.to eq '' } # advisor address
    end

    context 'uses coach for campy course' do
      let(:course) do
        Fabricate(:course,
                  groups: [groups(:be)],
                  kind: event_kinds(:fut),
                  location: 'somewhere',
                  state: 'completed',
                  training_days: 7,
                  express_fee: 'yada 500',
                  language_de: true,
                  language_fr: false,
                  language_it: true).tap do |course|
          course.update!(coach_id: people(:bulei).id)
        end
      end

      subject { csv.second.split(';') }

      its([28]) { is_expected.to eq 'Dr. Bundes Leiter / Scout' } # advisor name
      its([29]) { is_expected.to eq '' } # advisor address

      it 'has same headers' do
        expect(csv.first).to match(/^Name;Organisatoren;Kursnummer;Kursart;.*;LKB Name;.*;Anzahl Abgelehnte$/)
      end
    end
  end

  context 'camps' do
    let(:test_camp) { events(:schekka_camp).dup }
    let(:camps) { Event::Camp.all }
    let(:list)  { Export::Tabular::Events::List.new(camps) }
    let(:csv) { Export::Csv::Generator.new(list).call.split("\n")  }

    before do
      test_camp.update!(
        **required_attrs_for_camp_submit,
        camp_submitted_at: Time.zone.now.to_date
      )
    end

    context 'headers' do
      subject { csv.first }
      it {
        is_expected.to eq <<-CSV_HEADERS.chomp
Name;Organisatoren;Beschreibung;Lagerstatus;Ort / Adresse;Datum 1 Bezeichnung;Datum 1 Ort;Datum 1 Zeitraum;Datum 2 Bezeichnung;Datum 2 Ort;Datum 2 Zeitraum;Datum 3 Bezeichnung;Datum 3 Ort;Datum 3 Zeitraum;Notfallnummer;Kontaktperson Name;Kontaktperson Adresse;Kontaktperson PLZ;Kontaktperson Ort;Kontaktperson Haupt-E-Mail;Kontaktperson Telefonnummern;Hauptleitung Name;Hauptleitung Adresse;Hauptleitung PLZ;Hauptleitung Ort;Hauptleitung Haupt-E-Mail;Hauptleitung Telefonnummern;Motto;Kosten;Anmeldebeginn;Anmeldeschluss;Maximale Teilnehmerzahl;Externe Anmeldungen;J+S-Rahmen;Kanton / Land;Eingereicht;Eingereicht am;Leitungsteam erwartet;Teilnehmende erwartet;Anzahl Leitungsteam;Anzahl Teilnehmende;Anzahl Anmeldungen
        CSV_HEADERS
      }
    end

    context 'body' do
      let(:regular_camp_row) { csv.second.split(';') }
      let(:test_camp_row) { csv.last.split(';') }

      it 'shows camp j+s kind and canton' do
        expect(regular_camp_row[-9]).to eq ''
        expect(test_camp_row[-9]).to eq 'j_s_child'

        expect(regular_camp_row[-8]).to eq ''
        expect(test_camp_row[-8]).to eq 'be'
      end

      it 'shows camp submission status and date' do
        expect(regular_camp_row[-7]).to eq 'nein'
        expect(test_camp_row[-7]).to eq 'ja'

        expect(regular_camp_row[-6]).to eq ''
        expect(test_camp_row[-6]).to eq I18n.l(test_camp.camp_submitted_at)
      end

      it 'shows total expected (leading) participants' do
        expect(regular_camp_row[-5]).to eq '0'
        expect(test_camp_row[-5]).to eq '1'

        expect(regular_camp_row[-4]).to eq '0'
        expect(test_camp_row[-4]).to eq '3'
      end
    end
  end

  context 'for simple events' do
    let(:courses) { Event.where(id: event) }
    let(:event) { Fabricate(:event, groups: [groups(:be)], location: 'somewhere') }
    let(:csv) { Export::Csv::Generator.new(list).call.split("\n")  }

    context 'headers' do
      subject { csv.first }
      it { is_expected.to match(/^Name;Organisatoren;Beschreibung;Ort.*Anzahl Anmeldungen$/) }
      it { is_expected.not_to match(/LKB/) }
      it { is_expected.not_to match(/Kurssprache/) }
    end
  end

  def required_attrs_for_camp_submit
    {
      canton: 'be',
      location: 'foo',
      coordinates: '42',
      altitude: '1001',
      emergency_phone: '080011',
      landlord: 'georg',
      coach_confirmed: true,
      lagerreglement_applied: true,
      kantonalverband_rules_applied: true,
      j_s_kind: :j_s_child,
      j_s_rules_applied: true,
      expected_participants_leitung_f: 1,
      expected_participants_pio_f: 3,
      coach_id: Fabricate(:person).id,
      leader_id: Fabricate(:person).id,
      dates: [Fabricate(:event_date, start_at: Time.zone.now, finish_at: Time.zone.now)],
      groups: [groups(:schekka)]
    }
  end

end
