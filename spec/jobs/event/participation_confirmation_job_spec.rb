# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::ParticipationConfirmationJob do

  let(:participation) { Fabricate(:event_participation) }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  subject { Event::ParticipationConfirmationJob.new(participation) }

  it 'sends only confirmation email, not approval' do
    mailer = instance_double('mailer')
    allow(mailer).to receive(:deliver)
    expect(Event::ParticipationMailer).to receive(:confirmation).and_return(mailer)
    expect(Event::ParticipationMailer).to_not receive(:approval)
    subject.perform
  end

end
