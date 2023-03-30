# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'
require 'csv'

describe Export::Tabular::Events::BsvRow do

  let(:course) { fabricate_course }

  let(:row) { Export::Tabular::Events::BsvRow.new(course) }
  let(:bern) { Location.create!(name: 'Bern Stadt', canton: :be, zip_code: 3000) }
  subject { row }

  it { expect(row.fetch(:leader_count)).to eq 3 }
  it { expect(row.fetch(:language_count)).to eq 3 }

  it 'does render headers' do
    csv = Export::Tabular::Events::BsvList.csv([course])
    expect(CSV.parse(csv)).to have(2).row
  end

  it 'formats training_days' do
    course.training_days = 1
    expect(row.fetch(:training_days)).to eq '1'
    course.training_days = 1.5
    expect(row.fetch(:training_days)).to eq '1.5'
    course.training_days = nil
    expect(row.fetch(:training_days)).to be_blank
  end

  it 'formats bsv_days' do
    course.bsv_days = 1
    expect(row.fetch(:bsv_days)).to eq '1'
    course.bsv_days = 1.5
    expect(row.fetch(:bsv_days)).to eq '1.5'
    course.bsv_days = nil
    expect(row.fetch(:bsv_days)).to be_blank
  end

  it 'bsv_eligible_participants_count is zero' do
    expect(row.fetch(:bsv_eligible_participations_count)).to eq 0
  end

  it 'bsv_eligible_participants_count counts only ch residents aged 17 to 30' do
    participant = course.people.joins(event_participations: :roles)
     .find_by(event_roles: { type: Event::Course::Role::Participant.sti_name  })
    participant.update(birthday: '01.01.1990', location: bern)
    expect(row.fetch(:bsv_eligible_participations_count)).to eq 1
  end

  describe 'advanced_bsv_export' do
    before do
      course.bsv_days = 7
      create_eligible_participation(course, location: bern, age: 20)
      create_eligible_participation(course, location: bern, age: 12)
    end

    it 'bsv_eligible_attendance_summary' do
      expect(row.fetch(:all_participants_count)).to eq(8)
      expect(row.fetch(:all_participants_attendance_summary)).to eq('7x0, 2x7')
      expect(row.fetch(:all_participants_attendances)).to eq(14)
      expect(row.fetch(:bsv_eligible_attendance_summary)).to eq('2x7')
      expect(row.fetch(:bsv_eligible_participations_count)).to eq(2)
      expect(row.fetch(:bsv_eligible_attendances)).to eq(14)
    end
  end

  private

  def fabricate_course
    event_kind = Fabricate(:event_kind, vereinbarungs_id_fiver: '4242', kurs_id_fiver: '9932')
    course = Fabricate(:course, kind: event_kind)
    course.update!(language_de: true, language_fr: true, language_en: true)
    create_leader_participations(course)
    course
  end

  def create_eligible_participation(course, age: 20, location: nil, bsv_days: course.bsv_days)
    birthday = (course.dates.first.start_at - age.years).to_date
    person = Fabricate(:person, birthday: birthday, location: location)
    participation = Fabricate(:pbs_participation, event: course, person: person,
                              bsv_days: bsv_days, state: :attended)
    Fabricate(Event::Course::Role::Participant.name, participation: participation)
  end

  def create_leader_participations(course)
    Event::Course.role_types.each do |role|
      create_leader_participation(course, role.name)
    end
  end

  def create_leader_participation(course, role)
    person = Fabricate(:person)
    participation = Fabricate(:pbs_participation, event: course, person: person)
    Fabricate(role.to_sym, participation: participation)
  end

end
