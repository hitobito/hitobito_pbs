# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'
describe Import::PersonImporter do
  include CsvImportMacros

  let(:importer)  do
    Import::PersonImporter.new(data, groups(:schekka), Group::Abteilung::Sekretariat)
  end
  subject { importer }

  context 'notification when gaining access to more person data' do
    let(:parser)        { Import::CsvParser.new(File.read(path(:list))) }
    let(:mapping)       { headers_mapping(parser) }
    let(:data)          { parser.map_data(mapping) }
    let(:actuator)      { people(:al_schekka) }
    let(:foreign_group) { groups(:chaeib) }

    before do
      parser.parse
      Person.stamper = actuator
    end

    it 'is sent on role creation with more access' do
      person = Fabricate(:person, first_name: 'Ramiro', last_name: 'Brown',
                         email: 'ramiro_brown@example.com')
      Fabricate(Group::Abteilung::Sekretariat.name.to_sym, group: foreign_group, person: person)

      expect { importer.import }.to change { Delayed::Job.count }.by(1)
      expect(Delayed::Job.first.handler).to include('GroupMembershipJob')
    end

    it 'is not sent on role creation for new person' do
      expect { importer.import }.not_to change { Delayed::Job.count }
    end
  end
end
