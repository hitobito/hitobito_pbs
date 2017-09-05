# encoding: utf-8

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require 'csv'

describe Export::Tabular::People::ParticipationsFull do

  let(:person) { people(:child) }
  let(:participation) { Fabricate(:event_participation, person: person, event: events(:top_course), bsv_days: 4.5) }
  let(:list) { [participation] }
  let(:people_list) { Export::Tabular::People::ParticipationsFull.new(list) }

  subject { people_list.attribute_labels }

  context 'bsv days' do
    its([:bsv_days]) { should eq 'BSV-Tage' }
  end

  context 'integration' do
    let(:data) { Export::Tabular::People::ParticipationsFull.export(:csv, list) }
    let(:csv) { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

    subject { csv }

    its(:headers) { should include('BSV-Tage') }

    context 'first row' do
      subject { csv[0] }

      its(['Vorname'])      { should eq person.first_name }
      its(['Rollen'])       { should be_blank }
      its(['Anmeldedatum']) { should eq I18n.l(Time.zone.now.to_date) }
      its(['BSV-Tage'])     { should eq '4.5' }
    end
  end

end

