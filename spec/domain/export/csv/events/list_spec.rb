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

    its([22]) { is_expected.to eq '' } # advisor name
    its([23]) { is_expected.to eq '' } # advisor address
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

end
