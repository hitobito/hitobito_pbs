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

  context 'rejected' do
    let(:recipients) { [people(:bulei)] }
    let(:mail) { Event::ParticipationMailer.rejected(participation, recipients) }

    before do
      participation.update!(state: 'rejected')
    end

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Kursablehnung' }
      its(:to)      { should eq ['bulei@hitobito.example.com'] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/AL Schekka \/ Torben wurde für den Kurs Top Course abgelehnt./)
      end
    end
  end

  context 'confirmation' do
    let(:mail) { Event::ParticipationMailer.confirmation(participation) }

    context 'body' do
      before :all do
        template = CustomContent.find_or_create_by key: described_class::CONTENT_CONFIRMATION
        template.update!(
          label: 'Anlass: E-Mail Anmeldebestätigung',
          subject: 'Bestätigung der Anmeldung',
          body: "{recipient-name-with-salutation}<br/><br/>" \
                "Du hast dich für folgenden Anlass angemeldet:<br/><br/>" \
                "{event-details}<br/><br/>" \
                "Falls du ein Login hast, kannst du deine Anmeldung unter folgender Adresse einsehen " \
                "und eine Bestätigung ausdrucken:<br/><br/>{application-url}"
        )
      end

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
      before :all do
        template = CustomContent.find_or_create_by key: described_class::CONTENT_APPROVAL
        template.update!(
          label: 'Anlass: E-Mail Freigabe der Anmeldung',
          subject: 'Freigabe einer Kursanmeldung',
          body: "{recipient-names-with-salutation}<br/><br/>" \
            "{participant-name} hat sich für den folgenden Kurs angemeldet:<br/><br/>" \
            "{event-details}<br/><br/>" \
            "Bitte bestätige oder verwerfe diese Anmeldung unter der folgenden Adresse:<br/><br/>" \
            "{application-url}"
        )
      end

      it 'contains the names with a salutation' do
        is_expected.to match(/Hallo firsty, Hallo lasty/)
      end

    end
  end

  context 'cancel' do
    let(:mail) { Event::ParticipationMailer.cancel(participation.event, participation.person) }

    context 'body' do
      before :all do
        template = CustomContent.find_or_create_by key: described_class::CONTENT_CANCEL
        template.update!(
          label: 'Anlass: E-Mail Abmeldebestätigung',
          subject: 'Bestätigung der Abmeldung',
          body: "{recipient-name-with-salutation}<br/><br/>" \
            "Du hast dich von folgendem Anlass abgemeldet:<br/><br/>" \
            "{event-details}<br/><br/>"
        )
      end

      subject { mail.body }

      it 'contains the name with a salutation' do
        is_expected.to match(/Liebe\(r\) Torben/)
      end

    end
  end

end
