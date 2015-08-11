# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ParticipationConfirmationJob do

  let(:participation) { Fabricate(:pbs_participation) }
  let(:mailer) { instance_double('mailer') }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]

    allow(mailer).to receive(:deliver_now)
  end

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
