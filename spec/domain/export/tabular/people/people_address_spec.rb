# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require 'csv'

describe Export::Tabular::People::PeopleAddress do

  let(:person) { people(:bulei) }
  let(:simple_headers) do
    %w(Vorname Nachname Pfadiname Firmenname Firma Haupt-E-Mail Adresse PLZ Ort Land
       Geschlecht Geburtstag Rollen Titel Anrede Korrespondenzsprache Kantonalverband Id) << 'ID der Hauptebene'
  end
  let(:list) { Person.where(id: person) }
  let(:data) { Export::Tabular::People::PeopleAddress.csv(list) }
  let(:csv)  { CSV.parse(data, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  context 'export' do
    its(:headers) { should == simple_headers }

    context 'first row' do
      subject { csv[0] }

      its(['Vorname']) { should eq person.first_name }
      its(['Nachname']) { should eq person.last_name }
      its(['Haupt-E-Mail']) { should eq person.email }
      its(['Ort']) { should eq person.town }
      its(['Geschlecht']) { should eq person.gender_label }
      its(['Rollen']) { should eq 'Mitarbeiter GS Pfadibewegung Schweiz' }
      its(['Titel']) { should eq 'Dr.' }
      its(['Anrede']) { should eq 'Sehr geehrter Herr Dr. Leiter' }
      its(['PBS Personennummber']) { should be_nil }
      its(['Kantonalverband']) { is_expected.to eq 'CH' }
    end
  end

  context 'export_full' do
    its(:headers) { should include('Titel') }
    let(:data) { Export::Tabular::People::PeopleFull.csv(list) }

    context 'first row' do
      subject { csv[0] }

      its(['Titel']) { should eq 'Dr.' }
      its(['Anrede']) { should eq 'Sehr geehrter Herr Dr. Leiter' }
      its(['PBS Personennummer']) { should eq '337-180-612' }
    end
  end
end
