# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe Event::RemovedFromWaitingListJob do

  let(:participation) { Fabricate(:pbs_participation) }

  subject { Event::RemovedFromWaitingListJob.new(participation, people(:bulei), people(:al_schekka)) }

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  it 'sends email' do
    subject.perform
    expect(last_email).to be_present
    expect(last_email.body).to match(/Hallo #{people(:bulei).greeting_name}/)
    expect(last_email.body).to match(/wurde von #{people(:al_schekka)} von der Warteliste entfernt/)
  end

end
