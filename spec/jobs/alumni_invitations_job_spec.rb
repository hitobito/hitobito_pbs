# frozen_string_literal: true

require 'spec_helper'

describe AlumniInvitationsJob do
  it '#perform calls Alumni::Invitations#process and Alumni::Reminders#process' do
    invitations_double = instance_double('Alumni::Invitations')
    allow(Alumni::Invitations).to receive(:new).and_return(invitations_double)
    expect(invitations_double).to receive(:process).with(no_args)

    reminders_double = instance_double('Alumni::Reminders')
    allow(Alumni::Reminders).to receive(:new).and_return(reminders_double)
    expect(reminders_double).to receive(:process).with(no_args)

    subject.perform
  end
end
