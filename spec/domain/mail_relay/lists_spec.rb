# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe MailRelay::Lists do

  let(:message) do
    mail = Mail.new(File.read(Rails.root.join('spec', 'fixtures', 'email', 'regular.eml')))
    mail.header['X-Envelope-To'] = nil
    mail.header['X-Envelope-To'] = envelope_to
    mail.from = from
    mail
  end

  let(:envelope_to) { list.mail_name }

  let(:bll)  { Fabricate(Group::BottomLayer::Leader.name.to_sym, group: groups(:bottom_layer_one)).person }
  let(:bgl1) { Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_one)).person }
  let(:bgl2) { Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_two)).person }
  let(:ind)  { Fabricate(:person) }

  let(:list) { mailing_lists(:leaders) }

  let(:subscribers) { [ind, bll, bgl1] }

  let(:relay) { MailRelay::Lists.new(message) }
  subject { relay }

  context '#mailing_list' do
    let(:from) { people(:top_leader).email }
    its(:envelope_receiver_name) { should == list.mail_name }
    its(:mailing_list) { should == list }
    it { is_expected.to be_relay_address }
  end

  context '#receivers' do
    let(:from) { people(:top_leader).email }
    subject { relay.receivers }

    before do
      sub = list.subscriptions.new
      sub.subscriber = ind
      sub.save!

      subscribers
    end

    context 'with empty email' do
      before do
        ind.email = ''
        ind.save!
      end

      it { is_expected.to match_array([bll, bgl1].collect(&:email)) }
    end

    context 'with additional emails' do

      let!(:e1) { Fabricate(:additional_email, contactable: ind, mailings: true) }
      let!(:e2) { Fabricate(:additional_email, contactable: ind, mailings: false) }

      it { is_expected.to match_array([ind, bll, bgl1].collect(&:email) + [e1.email]) }
    end
  end

  context 'list admin' do
    before { create_individual_subscribers }

    context 'from main email' do
      let(:from) { people(:top_leader).email }

      it { is_expected.to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:potential_senders) { is_expected.to eq [people(:top_leader)] }
      its(:receivers) { is_expected.to match_array subscribers.collect(&:email) }

      it 'relays' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
      end
    end

    context 'from additional email' do
      let(:from) { people(:top_leader).reload.additional_emails.first.email }

      before { Fabricate(:additional_email, contactable: people(:top_leader)) }

      it { is_expected.to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:potential_senders) { is_expected.to eq [people(:top_leader)] }

      context 'with other people with same emails' do
        before do
          @other1 = Fabricate(Group::BottomLayer::Leader.name, group: groups(:bottom_layer_one)).person
          Fabricate(:additional_email, contactable: @other1, email: from)
          @other2 = Fabricate(Group::BottomLayer::Leader.name,
                              group: groups(:bottom_layer_one),
                              person: Fabricate(:person, email: from)).person
        end

        it { is_expected.to be_sender_allowed }
        its(:sender_email) { is_expected.to eq from }
        its(:potential_senders) { is_expected.to match_array([people(:top_leader), @other1, @other2]) }
      end
    end
  end

  context 'group email' do
    before { create_individual_subscribers }

    before do
      list.group.update!(email: 'toplayer@hitobito.example.com')
      Fabricate(:additional_email, contactable: list.group)
    end

    context 'from main email' do
      let(:from) { list.group.reload.email }

      it { is_expected.to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:receivers) { is_expected.to match_array subscribers.collect(&:email) }

      it 'relays' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
        expect(last_email.sender).to eq('leaders-bounces+toplayer=hitobito.example.com@localhost')
      end
    end

    context 'from additional email' do
      let(:from) { list.group.reload.additional_emails.first.email }

      it { is_expected.to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }

      it 'relays' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)
        expect(last_email.sender).to eq("leaders-bounces+#{from.tr('@', '=')}@localhost")
      end
    end
  end

  context 'additional sender' do
    let(:from) { 'news@example.com' }

    before { create_individual_subscribers }
    before { list.update_column(:additional_sender, from) }

    it { is_expected.to be_sender_allowed }
    its(:sender_email) { is_expected.to eq from }
    its(:potential_senders) { is_expected.to be_blank }
    its(:receivers) { is_expected.to match_array subscribers.collect(&:email) }

    it 'relays' do
      expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
    end
  end

  context 'list member' do
    before { create_individual_subscribers }

    context 'may post' do
      before { list.update_column(:subscribers_may_post, true) }
      before do
        Fabricate(:additional_email, contactable: bgl1)
        Fabricate(:additional_email, contactable: bgl1)
      end

      context 'from main email' do
        let(:from) { bgl1.reload.email }

        it { is_expected.to be_sender_allowed }
        its(:sender_email) { is_expected.to eq from }
        its(:potential_senders) { is_expected.to eq [bgl1] }
        its(:receivers) { is_expected.to match_array Person.mailing_emails_for(subscribers) }

        it 'relays' do
          expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

          expect(last_email.smtp_envelope_to).to match_array(Person.mailing_emails_for(subscribers))
          expect(last_email.sender).to eq("leaders-bounces+#{from.tr('@', '=')}@localhost")
        end

      end

      context 'from additional email' do
        let(:from) { bgl1.reload.additional_emails.last.email }

        it { is_expected.to be_sender_allowed }
        its(:sender_email) { is_expected.to eq from }
        its(:potential_senders) { is_expected.to eq [bgl1] }
        its(:receivers) { is_expected.to match_array Person.mailing_emails_for(subscribers) }

        it 'relays' do
          expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

          expect(last_email.smtp_envelope_to).to match_array(Person.mailing_emails_for(subscribers))
          expect(last_email.sender).to eq("leaders-bounces+#{from.tr('@', '=')}@localhost")
        end

      end
    end

    context 'may not post' do
      let(:from) { bgl1.email }
      before { list.update_column(:subscribers_may_post, false) }

      it { is_expected.not_to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:potential_senders) { is_expected.to eq [bgl1] }

      it 'rejects' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to eq [from]
        expect(last_email.from).to eq ["#{list.mail_name}-bounces@localhost"]
        expect(last_email.body).to match(/nicht berechtigt/)
      end
    end

  end

  context 'excluded person' do
    let(:from) { bgl2.email }

    before { create_individual_subscribers }
    before { list.update_column(:subscribers_may_post, true) }

    it { is_expected.not_to be_sender_allowed }
    its(:sender_email) { is_expected.to eq from }
    its(:potential_senders) { is_expected.to eq [bgl2] }

    it 'rejects' do
      expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(last_email.smtp_envelope_to).to eq [from]
      expect(last_email.from).to eq ["#{list.mail_name}-bounces@localhost"]
      expect(last_email.body).to match(/nicht berechtigt/)
    end
  end

  context 'anybody' do
    let(:from) { people(:bottom_member).email }

    context 'may post' do
      before { create_individual_subscribers }
      before { list.update_column(:anyone_may_post, true) }

      it { is_expected.to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:potential_senders) { is_expected.to eq [people(:bottom_member)] }
      its(:receivers) { is_expected.to match_array subscribers.collect(&:email) }

      it 'relays' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
        expect(last_email.from).to eq [from]
        expect(last_email.sender).to eq 'leaders-bounces+bottom_member=example.com@localhost'
      end

      context 'with invalid sender address' do
        before do
          message.from = nil
        end

        it { is_expected.not_to be_sender_allowed }
        its(:sender_email) { is_expected.to be_nil }
        its(:potential_senders) { is_expected.to be_blank }
        its(:receivers) { is_expected.to match_array subscribers.collect(&:email) }

        it 'does not relays' do
          expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
        end
      end
    end

    context 'may not post' do
      before { create_individual_subscribers }
      before { list.update_column(:anyone_may_post, false) }

      it { is_expected.not_to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:potential_senders) { is_expected.to eq [people(:bottom_member)] }

      it 'rejects' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to eq [from]
        expect(last_email.from).to eq ["#{list.mail_name}-bounces@localhost"]
        expect(last_email.body).to match(/nicht berechtigt/)
      end
    end
  end

  context 'foreign' do
    let(:from) { 'anybody@example.com' }

    context 'may post' do
      before { create_individual_subscribers }
      before { list.update_column(:anyone_may_post, true) }

      it { is_expected.to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }
      its(:receivers) { is_expected.to match_array subscribers.collect(&:email) }

      it 'relays' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
      end
    end

    context 'may not post' do
      before { create_individual_subscribers }
      before { list.update_column(:anyone_may_post, false) }

      it { is_expected.not_to be_sender_allowed }
      its(:sender_email) { is_expected.to eq from }

      it 'rejects' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to eq [from]
        expect(last_email.from).to eq ["#{list.mail_name}-bounces@localhost"]
        expect(last_email.body).to match(/nicht berechtigt/)
      end
    end
  end

  context 'anonymous' do
    let(:from) { nil }

    it { is_expected.not_to be_sender_allowed }
    its(:sender_email) { is_expected.to eq from }

    it 'does not relay' do
      expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context 'empty reply to' do

    let(:message) do
      message = <<-END
        Return-Path: <d.k@autoreply.example.com>
        From: d.k@autoreply.example.com
        Reply-To: <>
        To: \"hitobito\" <noreply@hitobito.ch>

        Hallo
        Vielen Dank f=FCr ihre Interesse.
      END

      mail = Mail.new(message)
      mail.header['X-Envelope-To'] = envelope_to
      mail
    end

    let(:from) { '<>' }

    it { is_expected.not_to be_sender_allowed }

    it 'rejects without email' do
      expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context 'bounce' do
    let(:from) { 'deamon@example.com' }

    context 'individual' do
      let(:envelope_to) { "#{list.mail_name}-bounces+test=example.com" }

      its(:sender_email) { is_expected.to eq from }

      it 'forwards bounce message' do
        expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

        expect(last_email.smtp_envelope_to).to eq ['test@example.com']
        expect(last_email.smtp_envelope_from).to eq "#{list.mail_name}-bounces@localhost"
        expect(last_email.from).to eq([from])
      end
    end

    context 'general' do
      let(:envelope_to) { "#{list.mail_name}-bounces" }

      it 'ignores message' do
        expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
      end
    end
  end

  context 'emails to app sender' do
    let(:from) { 'deamon@example.com' }

    let(:envelope_to) { MailRelay::Lists.app_sender_name }

    before { Fabricate(:mailing_list, group: list.group, mail_name: MailRelay::Lists.app_sender_name) }

    its(:sender_email) { is_expected.to eq from }

    it 'does not reject messages' do
      expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context 'non existing list' do
    let(:from) { people(:top_leader).email }
    let(:envelope_to) { 'foo' }

    it { is_expected.not_to be_relay_address }

    it 'does not relay' do
      expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  def create_individual_subscribers
    # single subscription
    sub = list.subscriptions.new
    sub.subscriber = ind
    sub.save!
    # excluded subscription
    sub = list.subscriptions.new
    sub.subscriber = bgl2
    sub.excluded = true
    sub.save!

    # create people
    subscribers
  end
end