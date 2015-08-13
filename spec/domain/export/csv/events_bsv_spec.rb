# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Export::Csv::Events::BsvRow do

  let(:person) { ndbjs_person }
  let(:course) { fabricate_course }

  let(:row) { Export::Csv::Events::BsvRow.new(course) }
  subject { row }

  it { expect(row.fetch(:leader_count)).to eq 3 }
  it { expect(row.fetch(:languages_count)).to eq 3 }

end

private
def fabricate_course
  event_kind = Fabricate(:event_kind, vereinbarungs_id_fiver: '4242', kurs_id_fiver: '9932')
  course = Fabricate(:course, kind: event_kind)
  course.update!(language_de: true, language_fr: true, language_en: true)
  create_leader_participations(course)
  course
end

def create_leader_participations(course)
  Event::Course.role_types.each do |role|
    create_leader_participation(course, role.name)
  end
end

def create_leader_participation(course, role)
  person = Fabricate(:person)
  participation = Fabricate(:event_participation, event: course, person: person)
  Fabricate(role.to_sym, participation: participation)
end

# languages
