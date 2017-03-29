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
  let(:participation) { Fabricate(:pbs_participation, person: person, event: course) }
  let(:approver) { Event::Approver.new(participation) }
  let(:mailer) { spy('mailer') }
  let(:approver_types) { Role.types_with_permission(:approve_applications).collect(&:sti_name) }

  before do
    Delayed::Worker.delay_jobs = false
    allow(Event::ParticipationMailer).to receive(:approval).and_return(mailer)
  end

  after do
    Delayed::Worker.delay_jobs = true
  end

  def create_application
    # The #application_create method is called by a callback of the
    # Event::Application model
    participation.create_application(priority_1: course)
  end

  describe '#application_created' do
    it 'creates no Event::Approval and sends no emails if no approval is required' do
      create_application
      expect(Event::Approval.count).to eq(0)
      expect(Event::ParticipationMailer).to_not have_received(:approval)
    end

    context 'approval required' do
      before do
        # Delete all people with approval permission
        Person.joins(:roles).where(roles: { type: approver_types }).delete_all

        # Ensure all layers have one approver
        Fabricate(Group::Abteilung::Abteilungsleitung.name, group: groups(:schekka))
        Fabricate(Group::Region::Regionalleitung.name, group: groups(:bern))
        Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:be))
        Fabricate(Group::Bund::Geschaeftsleitung.name, group: groups(:bund))

        course.update!(requires_approval_abteilung: true)
      end

      it 'creates no Event::Approval and sends no emails if approvee has no primary group' do
        person.update!(primary_group_id: nil)
        create_application

        expect(Event::Approval.count).to eq(0)
        expect(Event::ParticipationMailer).to_not have_received(:approval)
      end

      it 'creates no Event::Approval and sends no emails if participation has no application' do
        approver.application_created
        expect(Event::Approval.count).to eq(0)
        expect(Event::ParticipationMailer).to_not have_received(:approval)
      end

      it 'creates no Event::Approval and sends no emails if required layer is not in hierarchy' do
        person.update!(primary_group_id: groups(:bund).id)
        create_application

        expect(Event::Approval.count).to eq(0)
        expect(last_email).to be_nil
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

        context "from #{approvers}" do
          before do
            course.update!(requires_approval_abteilung: values[:abteilung],
                           requires_approval_region: values[:region],
                           requires_approval_kantonalverband: values[:kantonalverband],
                           requires_approval_bund: values[:bund])
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

      context 'having layers without approvers' do
        before do
          course.requires_approval_abteilung = true
          course.requires_approval_region = false
          course.requires_approval_kantonalverband = true
          course.requires_approval_bund = true
          course.save!

          # Delete all people with approval permission in Abteilung
          groups(:schekka).people.where(roles: { type: approver_types }).delete_all
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
        create_application
        expect(Event::ParticipationMailer).
          to have_received(:approval).once do |participation, people|
            expect(participation).to eq(participation)
            expect(people.length).to eq(1)
          end
      end
    end
  end

  describe '#approve' do
    it 'updates approval and approves application if no upper layers are found' do
      course.update!(requires_approval_abteilung: true)
      application = create_application
      approver.approve('all good', people(:bulei))

      expect(application.reload).to be_approved
      expect(application.approvals.size).to eq 1

      approval_abteilung = application.approvals.find_by_layer('abteilung')
      expect(approval_abteilung).to be_approved
      expect(approval_abteilung.comment).to eq 'all good'
      expect(approval_abteilung.approver).to eq people(:bulei)
      expect(approval_abteilung.approved_at).to be_within(10).of(Time.zone.now)

      expect(Event::ParticipationMailer).to have_received(:approval).once
    end

    it 'updates approval, sends email creates additional approval if more approving layers exist' do
      Fabricate(Group::Bund::Geschaeftsleitung.name, group: groups(:bund))

      course.update!(requires_approval_abteilung: true, requires_approval_bund: true)
      application = create_application
      approver.approve('all good', people(:bulei))

      expect(application.reload).not_to be_approved
      expect(application.approvals.size).to eq 2

      approval_abteilung = application.approvals.find_by_layer!('abteilung')
      approval_bund = application.approvals.find_by_layer!('bund')

      expect(approval_abteilung).to be_approved
      expect(approval_bund).not_to be_approved

      approver = Event::Approver.new(participation.reload)
      approver.approve('all good', people(:bulei))
      expect(approval_bund.reload).to be_approved

      expect(Event::ParticipationMailer).to have_received(:approval).twice do |participation,
                                                                               people|
        expect(participation).to eq(participation)
        expect(people.length).to eq(1)
      end
    end
  end

  describe '#reject' do

    it 'updates approval and rejects application' do
      course.update!(requires_approval_abteilung: true)
      application = create_application
      approver.reject('not so good', people(:bulei))
      expect(application.reload).to be_rejected
      expect(application.approvals.size).to eq 1

      approval_abteilung = application.approvals.find_by_layer('abteilung')
      expect(approval_abteilung).to be_rejected
      expect(approval_abteilung.comment).to eq 'not so good'
      expect(approval_abteilung.approver).to eq people(:bulei)
      expect(approval_abteilung.approved_at).to be_within(10).of(Time.zone.now)

      expect(Event::ParticipationMailer).to have_received(:approval).once
    end

  end

  describe '#current_approvers' do

    before do
      @rl = Fabricate(Group::Region::Regionalleitung.sti_name.to_sym, group: groups(:bern)).person
      @va1 = Fabricate(Group::Region::VerantwortungAusbildung.sti_name.to_sym, group: groups(:bern)).person
      @va2 = Fabricate(Group::Region::VerantwortungAusbildung.sti_name.to_sym, group: groups(:bern)).person

      course.update!(requires_approval_region: true)
      create_application
    end

    it 'contains all roles if none is selected' do
      expect(approver.current_approvers).to match_array([@rl, @va1, @va2])
    end

    it 'contains only selected roles' do
      groups(:bern).update!(application_approver_role: Group::Region::VerantwortungAusbildung.name)
      person.reload

      expect(approver.current_approvers).to match_array([@va1, @va2])
    end

    it 'contains all roles if no person with selected exists' do
      groups(:bern).update!(application_approver_role: Group::Region::Regionalleitung.name)
      @rl.destroy!
      person.reload

      expect(approver.current_approvers).to match_array([@va1, @va2])
    end

    context 'with multiple groups' do

      let(:corps) { Fabricate(Group::Region.name.to_sym, parent: groups(:be)) }

      before do
        groups(:bern).update!(parent: corps)

        @va_corps = Fabricate(Group::Region::VerantwortungAusbildung.sti_name.to_sym, group: corps).person
        @rl_corps = Fabricate(Group::Region::Regionalleitung.sti_name.to_sym, group: corps).person
      end

      it 'contains roles as selected by each group' do
        groups(:bern).update!(application_approver_role: Group::Region::Regionalleitung.name)
        corps.update!(application_approver_role: Group::Region::VerantwortungAusbildung.name)
        person.reload

        expect(approver.current_approvers).to match_array([@rl, @va_corps])
      end

      it 'does not contain person with different role in actual group' do
        corps.update!(application_approver_role: Group::Region::VerantwortungAusbildung.name)
        Fabricate(Group::Region::Kassier.sti_name.to_sym, group: groups(:bern), person: @rl_corps)
        person.reload

        expect(approver.current_approvers).to match_array([@rl, @va1, @va2, @va_corps])
      end

      it 'does not contain person with approver role in other group' do
        groups(:bern).update!(application_approver_role: Group::Region::Regionalleitung.name)
        corps.update!(application_approver_role: Group::Region::VerantwortungAusbildung.name)
        Fabricate(Group::Region::VerantwortungAusbildung.sti_name.to_sym, group: groups(:bern), person: @rl_corps)
        person.reload

        expect(approver.current_approvers).to match_array([@rl, @va_corps])
      end
    end

  end

end
