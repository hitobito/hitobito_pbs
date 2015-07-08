# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::Approver do

  let(:course) { Fabricate(:course, groups: [groups(:schekka)], kind: event_kinds(:lpk)) }
  let(:person) do
    Fabricate(Group::Abteilung::Sekretariat.name,
              group: groups(:schekka),
              person: Fabricate(:person, primary_group: groups(:schekka))).person
  end
  let(:participation) { Fabricate(:event_participation, person: person, event: course) }
  let(:approver) { Event::Approver.new(participation) }

  describe '#application_created' do
    def create_application
      # The #application_create method is called by a callback of the
      # Event::Application model
      participation.create_application(priority_1: course)
    end

    context 'no approval required' do
      it 'creates no Event::Approval and sends no emails' do
        create_application
        expect(Event::Approval.count).to eq(0)
        expect(last_email).to be_nil
      end
    end

    context 'approval required' do
      context 'for approver without primary_group' do
        before do
          person.primary_group = nil
          person.save!
        end

        it 'creates no Event::Approval and sends no emails' do
          create_application
          expect(Event::Approval.count).to eq(0)
          expect(last_email).to be_nil
        end
      end

      context 'for participation without application' do
        it 'creates no Event::Approval and sends no emails' do
          approver.application_created
          expect(Event::Approval.count).to eq(0)
          expect(last_email).to be_nil
        end
      end


      context 'all layers having approvers' do
        before do
          # Ensure all layers have approvers
          Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
          Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern))
          Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be))
          Fabricate(Group::Bund::Geschaeftsleitung.name, group: groups(:bund))
        end

        [{ abteilung: true, region: false, kantonalverband: false, bund: false,
           layer: 'abteilung' },
         { abteilung: true, region: true, kantonalverband: true, bund: true,
           layer: 'abteilung' },
         { abteilung: false, region: true, kantonalverband: false, bund: false,
           layer: 'region' },
         { abteilung: false, region: false, kantonalverband: true, bund: false,
           layer: 'kantonalverband' },
         { abteilung: false, region: false, kantonalverband: false, bund: true,
           layer: 'bund' }].each do |values|

          approvers = Event::Approval::LAYERS.map do |key|
            key if values[key.to_sym]
          end.compact.join(', ')

          context "requiring approvals from #{approvers}" do
            before do
              course.requires_approval_abteilung = values[:abteilung]
              course.requires_approval_region = values[:region]
              course.requires_approval_kantonalverband = values[:kantonalverband]
              course.requires_approval_bund = values[:bund]
              course.save!
            end

            it "creates Event::Approval for layer #{values[:layer]}" do
              application = create_application
              expect(Event::Approval.count).to eq(1)
              approval = Event::Approval.first
              expect(approval.layer).to eq(values[:layer])
              expect(approval.application).to eq(application)
              expect(approval.approved).to be_falsy
              expect(approval.rejected).to be_falsy
              expect(approval.comment).to be_nil
              expect(approval.approved_at).to be_nil
              expect(approval.approver).to be_nil
              expect(approval.approvee).to eq(person)
            end
          end
        end
      end

      context 'having layers without approvers' do
        before do
          course.requires_approval_abteilung = true
          course.requires_approval_region = false
          course.requires_approval_kantonalverband = true
          course.requires_approval_bund = true
          course.save!

          # Delete all people with approval permission in Abteilung
          approval_roles = [Group::Abteilung::Abteilungsleitung, Group::Abteilung::AbteilungsleitungStv]
          groups(:schekka).people.where('roles.type IN (?)', approval_roles).delete_all

          # Ensure Kantonalverband has an approver
          Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be))
        end

        it 'skips to kantonalverband which has approvers' do
          application = create_application
          expect(Event::Approval.count).to eq(1)
          approval = Event::Approval.first
          expect(approval.layer).to eq('kantonalverband')
          expect(approval.application).to eq(application)
          expect(approval.approved).to be_falsy
          expect(approval.rejected).to be_falsy
          expect(approval.comment).to be_nil
          expect(approval.approved_at).to be_nil
          expect(approval.approver).to be_nil
          expect(approval.approvee).to eq(person)
        end
      end

      it 'sends email to all roles from affected layer(s) with permission :approve_applications' do
        # expect(last_email).to be_present
        # expect(last_email.body).to match(/Hallo #{recipient.greeting_name}/)
        # expect(last_email.body).not_to match(/#{recipient.reload.reset_password_token}/)
      end

    end


  end

end
