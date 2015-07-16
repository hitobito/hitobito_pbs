# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require_relative '../../support/fabrication.rb'

describe Event::Course do

  let(:event) { Fabricate(:course, groups: [groups(:be)], kind: event_kinds(:lpk)) }

  subject do
    Fabricate(Event::Role::Leader.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    Fabricate(Event::Role::AssistantLeader.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    Fabricate(Event::Course::Role::Participant.name.to_sym,
              participation: Fabricate(:pbs_participation, event: event))
    event.reload
  end

  describe '.role_types' do
    subject { Event::Course.role_types }

    it { is_expected.to include(Event::Course::Role::Participant) }
    it { is_expected.not_to include(Event::Role::Participant) }
  end

  context '#application_possible?' do
    before { subject.state = 'application_open' }

    context 'without opening date' do
      it { is_expected.to be_application_possible }
    end

    context 'with opening date in the past' do
      before { subject.application_opening_at = Date.today - 1 }
      it { is_expected.to be_application_possible }

      context 'in other state' do
        before { subject.state = 'application_closed' }
        it { is_expected.not_to be_application_possible }
      end
    end

    context 'with opening ndate today' do
      before { subject.application_opening_at = Date.today }
      it { is_expected.to be_application_possible }
    end

    context 'with opening date in the future' do
      before { subject.application_opening_at = Date.today + 1 }
      it { is_expected.not_to be_application_possible }
    end

    context 'with closing date in the past' do
      before { subject.application_closing_at = Date.today - 1 }
      it { is_expected.not_to be_application_possible }
    end

    context 'in other state' do
      before { subject.state = 'created' }
      it { is_expected.not_to be_application_possible }
    end

  end

  describe '.requires_approval' do
    it 'is false if no approval group is defined' do
      expect(event.requires_approval).to be_falsy
    end

    it 'is true if all approval groups are defined' do
      event.requires_approval_abteilung = true
      event.requires_approval_region = true
      event.requires_approval_kantonalverband = true
      event.requires_approval_bund = true
      event.save!
      expect(event.requires_approval).to be_truthy
    end

    %w(requires_approval_abteilung requires_approval_region requires_approval_kantonalverband
       requires_approval_bund).each do |approval_attr|
      it "is true if .#{approval_attr} is true" do
        event.send(approval_attr + '=', true)
        event.save!
        expect(event.requires_approval).to be_truthy
      end
    end
  end


end
