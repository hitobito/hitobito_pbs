# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Export::Csv::People::ParticipationNdbjsRow do

  let(:person) { ndbjs_person }
  let(:participation) { Fabricate(:event_participation, person: person, event: events(:top_course)) }

  let(:row) { Export::Csv::People::ParticipationNdbjsRow.new(participation) }
  subject { row }

  it { expect(row.fetch(:j_s_number)).to eq '1695579' }
  it { expect(row.fetch(:gender)).to eq 1 }
  it { expect(row.fetch(:first_name)).to eq 'Peter' }
  it { expect(row.fetch(:last_name)).to eq 'Muster' }
  it { expect(row.fetch(:birthday)).to eq '11.06.1980' }
  it { expect(row.fetch(:ahv_number)).to eq '789.80.267.213' }
  it { expect(row.fetch(:address)).to eq 'Hauptstrasse 33' }
  it { expect(row.fetch(:zip_code)).to eq '4000' }
  it { expect(row.fetch(:town)).to eq 'Basel' }
  it { expect(row.fetch(:canton)).to eq 'BS' }
  it { expect(row.fetch(:country)).to eq 'CH' }
  it { expect(row.fetch(:phone_private)).to eq '11 12 13' }
  it { expect(row.fetch(:phone_work)).to eq '42 42 42' }
  it { expect(row.fetch(:phone_mobile)).to eq '99 99 99' }
  it { expect(row.fetch(:phone_fax)).to eq '33 33 33' }
  it { expect(row.fetch(:nationality_j_s)).to eq 'FL' }
  it { expect(row.fetch(:first_language)).to eq 'I' }
  it { expect(row.fetch(:profession)).to eq 3 }
  it { expect(row.fetch(:organisation)).to eq nil }
  it { expect(row.fetch(:association)).to eq nil }
  it { expect(row.fetch(:activity)).to eq 1 }
  it { expect(row.fetch(:attachments)).to eq 1 }

end

private
def ndbjs_person
  Location.create!(zip_code: 4000, name: 'Basel', canton: 'bs')
  person = Fabricate(:person,
                     email: 'foo@example.com',
                     first_name: 'Peter',
                     last_name: 'Muster',
                     birthday: '11.06.1980',
                     gender: 'm',
                     j_s_number: '1695579',
                     ahv_number: '789.80.267.213',
                     address: 'Hauptstrasse 33',
                     zip_code: '4000',
                     town: 'Basel',
                     country: 'CH',
                     nationality_j_s: 'FL',
                     correspondence_language: 'it'
                    )
  create_contactables(person)
  person
end

def create_contactables(person)
  Fabricate(:phone_number, contactable: person, label: 'Privat', number: '11 12 13')
  Fabricate(:phone_number, contactable: person, label: 'Arbeit', number: '42 42 42')
  Fabricate(:phone_number, contactable: person, label: 'Mobil', number: '99 99 99')
  Fabricate(:phone_number, contactable: person, label: 'Fax', number: '33 33 33')
end
