# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::DiscardedCourseParticipationJob do

  let(:event) { participation.event }
  let(:previous_state) { 'assigned' }
  let(:job) { Event::DiscardedCourseParticipationJob.new(participation, previous_state) }
  let(:participation) { event_participations(:top_participant) }

  before do
    msg = double('Message', deliver_now: true)
    allow(Event::ParticipationMailer).to receive(:canceled) { msg }
    allow(Event::ParticipationMailer).to receive(:rejected) { msg }
  end

  context 'assigned participation' do

    describe '#perform' do
      it 'does not send any mails' do
        expect(Event::ParticipationMailer).not_to receive(:canceled)
        expect(Event::ParticipationMailer).not_to receive(:rejected)
        job.perform
      end
    end

  end

  context 'canceled participation' do

    before do
      participation.update!(state: 'canceled', canceled_at: Time.zone.now)
    end

    describe '#perform' do

      it 'contains abteilungsleitung and kursleitung' do
        expect(Event::ParticipationMailer).to receive(:canceled)
          .with(participation, match_array(people(:al_schekka, :bulei)))
        job.perform
      end

      context 'with organizers' do
        before do
          @bund = Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)).person
          @kanton1 = Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person
          @kanton2 = Fabricate(Group::Kantonalverband::VerantwortungAusbildung.name.to_sym, group: groups(:be)).person
          @region = Fabricate(Group::Region::VerantwortungAusbildung.name.to_sym, group: groups(:bern)).person

          participation.update!(person: Fabricate(Group::Region::Redaktor.name.to_sym, group: groups(:bern)).person)
        end

        it 'contains and kursleitung and organizer' do
          expect(Event::ParticipationMailer).to receive(:canceled)
            .with(participation, match_array([people(:bulei), @kanton1, @kanton2]))
          job.perform
        end
      end

      context 'with application approvers' do
        before do
          @bund = Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)).person
          @kanton = Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person
          @region = Fabricate(Group::Region::Regionalleitung.name.to_sym, group: groups(:bern)).person

          event.update!(requires_approval_region: true,
                        requires_approval_kantonalverband: true,
                        requires_approval_bund: true)
          participation.update!(person: Fabricate(Group::Region::Redaktor.name.to_sym, group: groups(:bern)).person,
                                application: Event::Application.new(priority_1: event))
          participation.application.approvals.first.update!(approved: true,
                                                            approver: @region,
                                                            current_occupation: 'chief',
                                                            current_level: 'junior',
                                                            occupation_assessment: 'good',
                                                            strong_points: 'strong',
                                                            weak_points: 'weak')
          participation.application.approvals.create!(layer: 'kantonalverband',
                                                      approved: true,
                                                      approver: @kanton,
                                                      current_occupation: 'chief',
                                                      current_level: 'junior',
                                                      occupation_assessment: 'good',
                                                      strong_points: 'strong',
                                                      weak_points: 'weak')
          participation.application.approvals.create!(layer: 'bund')
        end

        it 'contains kursleitung and application approvers' do
          expect(Event::ParticipationMailer).to receive(:canceled)
            .with(participation, match_array([people(:bulei), @kanton, @region]))
          job.perform
        end

        context 'previously applied' do
          let(:previous_state) { 'applied' }

          before do
            @organizer = Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person
          end

          it 'does not send mails to kursleitung' do
            expect(Event::ParticipationMailer).to receive(:canceled)
              .with(participation, match_array([@kanton, @region, @organizer]))
            job.perform
          end
        end
      end

    end

  end

  context 'rejected participation' do

    before do
      participation.update!(state: 'rejected')
    end

    describe '#perform' do
      before do
        @bund = Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)).person
        @kanton = Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person
        @region = Fabricate(Group::Region::Regionalleitung.name.to_sym, group: groups(:bern)).person

        event.update!(requires_approval_region: true,
                      requires_approval_kantonalverband: true,
                      requires_approval_bund: true)
        participation.update!(person: Fabricate(Group::Region::Redaktor.name.to_sym, group: groups(:bern)).person,
                              application: Event::Application.new(priority_1: event))
        participation.application.approvals.first.update!(
          approved: true,
          approver: @region,
          current_occupation: 'chief',
          current_level: 'junior',
          occupation_assessment: 'good',
          strong_points: 'strong',
          weak_points: 'weak')
        participation.application.approvals.create!(
          layer: 'kantonalverband',
          approved: true,
          approver: @kanton,
          current_occupation: 'chief',
          current_level: 'junior',
          occupation_assessment: 'good',
          strong_points: 'strong',
          weak_points: 'weak')
        participation.application.approvals.create!(layer: 'bund')
      end

      it 'contains application approvers' do
        expect(Event::ParticipationMailer).to receive(:rejected)
          .with(participation, match_array([@kanton, @region]))
        job.perform
      end

    end

  end

end
