# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ParticipationConfirmationJob do

  let(:participation) { Fabricate(:pbs_participation) }
  let(:mailer) { double('mailer') }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]

    allow(mailer).to receive(:deliver_now)
  end

  context 'course' do
    it 'sends only confirmation email, not approval' do
      expect(Event::ParticipationMailer).to receive(:confirmation).and_return(mailer)
      expect(Event::ParticipationMailer).to_not receive(:approval)
      Event::ParticipationConfirmationJob.new(participation, participation.person).perform
    end

    it 'sends only confirmation other email, if user is not participation user' do
      expect(Event::ParticipationMailer).to receive(:confirmation_other).and_return(mailer)
      expect(Event::ParticipationMailer).to_not receive(:approval)
      Event::ParticipationConfirmationJob.new(participation, people(:bulei)).perform
    end
  end

  context 'camp' do
    let(:event) { events(:schekka_camp) }
    let(:participation) { Fabricate(:pbs_participation, event: event) }

    context 'without leaders' do
      before { event.participations.destroy_all }

      it 'sends only confirmation email, not information' do
        expect(Event::ParticipationMailer).to receive(:confirmation).and_return(mailer)
        expect(Event::ParticipationMailer).to_not receive(:approval)
        expect(Event::CampMailer).to_not receive(:participant_applied_info)
        Event::ParticipationConfirmationJob.new(participation, participation.person).perform
      end
    end

    context 'with leaders' do

      before do
        @l1 = Fabricate(Event::Camp::Role::Leader.name, participation: Fabricate(:pbs_participation, event: event))
        @l2 = Fabricate(Event::Camp::Role::Leader.name, participation: Fabricate(:pbs_participation, event: event))
        Fabricate(Event::Camp::Role::AssistantLeader.name, participation: Fabricate(:pbs_participation, event: event))
      end

      it 'sends confirmation and information email' do
        expect(Event::ParticipationMailer).to receive(:confirmation).and_return(mailer)
        expect(Event::CampMailer).to receive(:participant_applied_info).with(
                                       participation,
                                       [people(:bulei),
                                        @l1.participation.person,
                                        @l2.participation.person]).
                                       and_return(mailer)
        expect(Event::ParticipationMailer).to_not receive(:approval)
        Event::ParticipationConfirmationJob.new(participation, participation.person).perform
      end

      it 'sends only confirmation other email, if user is not participation user' do
        expect(Event::ParticipationMailer).to receive(:confirmation_other).and_return(mailer)
        expect(Event::ParticipationMailer).to_not receive(:approval)
        expect(Event::CampMailer).to_not receive(:participant_applied_info)
        Event::ParticipationConfirmationJob.new(participation, people(:bulei)).perform
      end

      it 'does not get confused when participation is leader in another camp' do
        other = Fabricate(:pbs_camp, groups: [groups(:schekka)])
        l3 = Fabricate(Event::Camp::Role::Leader.name, participation: Fabricate(:pbs_participation, event: other))
        Fabricate(Event::Camp::Role::Participant.name, participation: Fabricate(:pbs_participation, event: event, person: l3.person))

        expect(Event::ParticipationMailer).to receive(:confirmation).and_return(mailer)
        expect(Event::CampMailer).to receive(:participant_applied_info).with(
                                       participation,
                                       [people(:bulei),
                                        @l1.participation.person,
                                        @l2.participation.person]).
                                       and_return(mailer)
        expect(Event::ParticipationMailer).to_not receive(:approval)
        Event::ParticipationConfirmationJob.new(participation, participation.person).perform
      end

    end
  end

end
