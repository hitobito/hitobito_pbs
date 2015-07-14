# encoding: utf-8

#  Copyright (c) 2012-2015, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ApprovalRequestJob do

  let(:course) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk)) }
  let(:person) do
    Fabricate(Group::Abteilung::Sekretariat.name,
              group: groups(:schekka),
              person: Fabricate(:person, primary_group: groups(:schekka))).person
  end
  let(:participation) do
    Fabricate(:event_participation,
              person: person,
              event: course,
              application: application)
  end
  let(:application) do
    Fabricate(:event_application,
              priority_1: course,
              priority_2: course)
  end


  let(:mailer) { spy('mailer') }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  subject(:job) { Event::ApprovalRequestJob.new(participation) }

  context '#send_approval' do
    let(:layer) { 'region' }

    before { course.update!(requires_approval_region: true) }

    it 'sends mail to all approvers in layer' do
      # Make sure there are no seeded persons with approval permissions
      approval_roles = [Group::Region::Regionalleitung, Group::Region::VerantwortungAusbildung]
      groups(:schekka).people.where(roles: { type: approval_roles }).destroy_all

      leitung = Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern)).person
      ausbildung = Fabricate(Group::Region::VerantwortungAusbildung.name,
                             group: groups(:bern)).person

      # These people should no receive the email
      Fabricate(Group::Region::Regionalleitung.name, group: groups(:oberland))
      Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
      Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be))
      Fabricate(Group::Bund::Geschaeftsleitung.name, group: groups(:bund))

      application.approvals.create!(layer: layer)

      expect(Event::ParticipationMailer).to receive(:approval) do |participation, people|
        expect(participation).to eq(participation)
        expect(people).to match_array([leitung, ausbildung])

        mailer
      end
      job.perform
    end
  end

end
