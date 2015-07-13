# encoding: utf-8

#  Copyright (c) 2012-2015, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ApprovalRequestJob do

  let(:course) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk)) }
  let(:role) { Group::Abteilung::Sekretariat.name }
  let(:group) { groups(:schekka) }
  let(:person) do
    Fabricate(role,
              group: group,
              person: Fabricate(:person, primary_group: group)).person
  end
  let(:participation) { Fabricate(:event_participation, person: person, event: course) }

  let(:mailer) { spy('mailer') }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  subject(:job) { Event::ApprovalRequestJob.new(layer, participation) }

  context '#send_approval' do
    let(:layer) { 'region' }

    before { course.update!(requires_approval_region: true) }

    it 'sends mail to all approvers in layer' do
      # Make sure there are no seeded persons with approval permissions
      approval_roles = [Group::Region::Regionalleitung, Group::Region::VerantwortungAusbildung]
      groups(:schekka).people.where(roles: { type: approval_roles }).delete_all

      leitung = Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern)).person
      ausbildung = Fabricate(Group::Region::VerantwortungAusbildung.name,
                             group: groups(:bern)).person

      # These people should no receive the email
      Fabricate(Group::Region::Regionalleitung.name, group: groups(:oberland))
      Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
      Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be))
      Fabricate(Group::Bund::Geschaeftsleitung.name, group: groups(:bund))

      expect(Event::ParticipationMailer).to receive(:approval) do |participation, people|
        expect(participation).to eq(participation)
        expect(people).to match_array([leitung, ausbildung])

        mailer
      end
      job.perform
    end
  end

  context '#approvers' do
    before do
      # Make sure there are no seeded persons with approval permissions
      approver_types = Role.types_with_permission(:approve_applications).collect(&:sti_name)
      Person.joins(roles: :group).where(roles: { type: approver_types })

      Fabricate(Group::Abteilung::Abteilungsleitung.name, group: abteilung)
      Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be))
      Fabricate(Group::Bund::Geschaeftsleitung.name, group: groups(:bund))
    end

    let(:region1) { groups(:be).children.create!(name: 'region1', type: Group::Region.sti_name) }
    let(:region2) { region1.children.create!(name: 'region2', type: Group::Region.sti_name) }
    let(:region3) { region2.children.create!(name: 'region3', type: Group::Region.sti_name) }
    let(:abteilung) { region3.children.create!(name: 'abteilung', type: Group::Abteilung.sti_name) }
    let(:group) { abteilung.children.create!(name: 'woelfe', type: Group::Woelfe.sti_name) }

    let(:layer) { 'region' }
    let(:role) { Group::Woelfe::Wolf.name }
    let(:approvers) { job.approvers }

    it 'returns approvers of all regions in hierarchy' do
      Fabricate(Group::Region::Regionalleitung.name, group: region1)
      Fabricate(Group::Region::Regionalleitung.name, group: region2)
      Fabricate(Group::Region::VerantwortungAusbildung.name, group: region2)
      Fabricate(Group::Region::Regionalleitung.name, group: region3)
      expect(approvers.length).to eq(4)
    end

    it 'does not return approvers twice' do
      p = Fabricate(Group::Region::Regionalleitung.name, group: region1).person
      Fabricate(Group::Region::Regionalleitung.name, group: region2, person: p)
      expect(approvers.length).to eq(1)
    end

    it 'does not return non-approvers or approvers from other regions' do
      Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern))
      Fabricate(Group::Region::Coach.name, group: region2)
      expect(approvers.length).to eq(0)
    end

    it 'is fine with regions that have no approvers' do
      Fabricate(Group::Region::Regionalleitung.name, group: region2)
      Fabricate(Group::Region::Regionalleitung.name, group: region3)
      expect(approvers.length).to eq(2)
    end

    it 'returns no approver if no region in hierarchy has an approver' do
      expect(approvers.length).to eq(0)
    end
  end

end
