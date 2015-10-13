# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::CanceledCampParticipationJob do

  let(:event) { participation.event }
  let(:job) { Event::CanceledCampParticipationJob.new(participation) }
  let(:participation) { event_participations(:schekka_camp_participant) }


  context '#camp_leaders' do
    let(:camp_leaders) { job.send(:camp_leaders) }

    it 'contains all leaders' do
      l1 = Fabricate(Event::Camp::Role::Leader.name, participation: Fabricate(:event_participation, event: event)).participation
      Fabricate(Event::Camp::Role::Leader.name, participation: l1)
      Fabricate(Event::Camp::Role::AssistantLeader.name, participation: Fabricate(:event_participation, event: event))

      expect(camp_leaders).to eq([people(:bulei), l1.person])
    end
  end

  context '#perform' do
    let(:mailer) { double('mailer') }

    before { allow(mailer).to receive(:deliver_now) }

    it 'does nothing if participation was un-canceled again' do
      participation.update!(state: 'assigned')
      expect(Event::CampMailer).not_to receive(:participant_canceled_info)
      job.perform
    end

    it 'sends mail to recipients' do
      participation.update!(state: 'canceled')
      expect(Event::CampMailer).to receive(:participant_canceled_info).with(participation, [people(:bulei)]).and_return(mailer)
      job.perform
    end
  end
end
