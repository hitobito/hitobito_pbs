#  Copyright (c) 2017-2023, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"
require "csv"

describe Export::Tabular::People::ParticipationsFull do
  let(:person) { people(:child) }
  let(:participation) {
    Fabricate(:pbs_participation, participant: person, event: events(:top_course), bsv_days: 4.5)
  }
  let(:list) { Event::Participation.where(id: participation.id) }
  let(:people_list) { Export::Tabular::People::ParticipationsFull.new(list) }

  subject { people_list.attribute_labels }

  context "bsv days" do
    its([:bsv_days]) { is_expected.to eq "BSV-Tage" }
  end

  context "integration" do
    let(:data) {
      Export::Tabular::People::ParticipationsFull.export(:csv,
        list).delete_prefix(Export::Csv::UTF8_BOM)
    }
    let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

    subject { csv }

    its(:headers) { is_expected.to include("BSV-Tage") }

    context "first row" do
      subject { csv[0] }

      its(["Vorname"]) { is_expected.to eq person.first_name }
      its(["Rollen"]) { is_expected.to be_blank }
      its(["Anmeldedatum"]) { is_expected.to eq I18n.l(Time.zone.now.to_date) }
      its(["BSV-Tage"]) { is_expected.to eq "4.5" }
    end
  end
end
