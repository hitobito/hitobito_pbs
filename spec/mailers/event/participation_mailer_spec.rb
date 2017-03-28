# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event::ParticipationMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end


  let(:participation) { event_participations(:top_participant) }

  context 'canceled' do
    let(:recipients) { [people(:bulei)] }
    let(:mail) { Event::ParticipationMailer.canceled(participation, recipients) }

    before do
      participation.update!(state: 'canceled', canceled_at: '1.7.2015')
    end

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Kursabmeldung' }
      its(:to)      { should eq ['bulei@hitobito.example.com'] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/AL Schekka \/ Torben wurde per 01.07.2015 vom Kurs Top Course abgemeldet./)
      end
    end
  end

  context 'confirmation' do
    let(:mail) { Event::ParticipationMailer.confirmation(participation) }

    context 'body' do
      subject { mail.parts.first.body }

      it 'contains the name with a salutation' do
        is_expected.to match(/Liebe\(r\) Torben/)
      end

    end
  end

  context 'approval' do
    let(:approvers) do
      [Fabricate(:person, email: 'approver0@example.com', first_name: 'firsty'),
       Fabricate(:person, email: 'approver1@example.com', first_name: 'lasty')]
    end
    let(:mail) { Event::ParticipationMailer.approval(participation, approvers) }

    context 'body' do
      subject { mail.body }

      it 'contains the names with a salutation' do
        is_expected.to match(/Hallo firsty, Hallo lasty/)
      end

    end
  end

  context 'cancel' do
    let(:mail) { Event::ParticipationMailer.cancel(participation.event, participation.person) }

    context 'body' do
      subject { mail.body }

      it 'contains the name with a salutation' do
        is_expected.to match(/Liebe\(r\) Torben/)
      end

    end
  end

end
