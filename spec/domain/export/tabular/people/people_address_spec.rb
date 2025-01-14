#  Copyright (c) 2012-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"
require "csv"

describe Export::Tabular::People::PeopleAddress do
  let(:person) { people(:bulei) }
  let(:ability) { Ability.new(person) }

  let(:simple_headers) do
    %w[Vorname Nachname Pfadiname Firmenname Firma Haupt-E-Mail Adresse PLZ Ort Land
      Hauptebene Rollen Titel Anrede Sprache Digitale\ Korrespondenz\ bevorzugt
      Kantonalverband Id] << "Id der Hauptebene"
  end
  let(:list) { Person.where(id: person) }
  let(:data) { Export::Tabular::People::PeopleAddress.csv(list).delete_prefix(Export::Csv::UTF8_BOM) }
  let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  context "export" do
    its(:headers) { is_expected.to eql simple_headers }

    it "accepts ability in constructor" do
      expect(Export::Tabular::People::PeopleAddress.csv(list, ability)).to be_present
    end

    context "first row" do
      subject { csv[0] }

      its(["Vorname"]) { is_expected.to eq person.first_name }
      its(["Nachname"]) { is_expected.to eq person.last_name }
      its(["Haupt-E-Mail"]) { is_expected.to eq person.email }
      its(["Ort"]) { is_expected.to eq person.town }
      its(["Rollen"]) { is_expected.to eq "Mitarbeiter*in GS Pfadibewegung Schweiz" }
      its(["Titel"]) { is_expected.to eq "Dr." }
      its(["Anrede"]) { is_expected.to eq "Sehr geehrter Herr Dr. Leiter" }
      its(["Kantonalverband"]) { is_expected.to eq "CH" }
    end
  end

  context "export_full" do
    let(:data) { Export::Tabular::People::PeopleFull.csv(list) }

    before do
      person.update(pbs_number: "337-180-612")
    end

    its(:headers) { is_expected.to include("Titel") }

    it "accepts ability in constructor" do
      expect(Export::Tabular::People::PeopleFull.csv(list, ability)).to be_present
    end

    context "first row" do
      subject { csv[0] }

      its(["Titel"]) { is_expected.to eq "Dr." }
      its(["Anrede"]) { is_expected.to eq "Sehr geehrter Herr Dr. Leiter" }
      its(["PBS Personennummer"]) { is_expected.to eq "337-180-612" }
    end
  end
end
