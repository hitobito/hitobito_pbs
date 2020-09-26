# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventsPbsHelper do

  include FormatHelper

  context '#expected_participants_value_present?' do

    subject { events(:schekka_camp) }

    it 'returns true if at least one value present' do
      subject.update(expected_participants_pio_f: 3)
      expect(expected_participants_value_present?(subject)).to be true
    end

    it 'returns false if no value present' do
      expect(expected_participants_value_present?(subject)).to be false
    end

  end

  context '#camp_list_permitting_kantonalverbaende' do

    subject { camp_list_permitting_kantonalverbaende }

    context 'as kantonsleitung' do
      let(:current_user) do
        person = Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:zh)).person
        Fabricate(Group::Kantonalverband::VerantwortungKrisenteam.name, group: groups(:be), person: person)
        Fabricate(Group::Kantonalverband::VerantwortungKrisenteam.name, group: groups(:zh), person: person)
        person
      end

      it { is_expected.to eq(groups(:be, :zh)) }
    end

    context 'as bundesleitung' do
      let(:current_user) { people(:bulei) }

      it { is_expected.to eq([]) }
    end
  end

  context '#camp_list_permitted_cantons' do

    subject { camp_list_permitted_cantons }

    context 'as kantonsleitung' do
      let(:current_user) do
        person = Fabricate(Group::Kantonalverband::Kantonsleitung.name, group: groups(:zh)).person
        Fabricate(Group::Kantonalverband::VerantwortungKrisenteam.name, group: groups(:be), person: person)
        Fabricate(Group::Kantonalverband::VerantwortungKrisenteam.name, group: groups(:zh), person: person)
        person
      end

      before do
        groups(:be).update!(cantons: %w(be fr ag))
        groups(:zh).update!(cantons: %w(zh ag))
      end

      it do
        is_expected.to eq([['ag', 'Aargau'],
                           ['be', 'Bern'],
                           ['fr', 'Freiburg'],
                           ['zh', 'Zürich']])
      end
    end

    context 'as bundesleitung' do
      let(:current_user) { people(:bulei) }

      it { is_expected.to eq([]) }
    end
  end

  context '#camp_visiting_info' do

    subject { events(:schekka_camp) }
    before { subject.update(al_visiting: true) }

    it 'shows value without date if date missing' do
      expect(camp_visiting_info(subject.al_visiting, subject.al_visiting_date)).to eq('Besucht das Lager')
    end

    it 'shows date if date present' do
      subject.update(al_visiting_date: Date.parse('15.05.2011'))
      expect(camp_visiting_info(subject.al_visiting, subject.al_visiting_date)).to eq('Besucht das Lager am 15.05.2011')
    end

    it 'shows no date if al not visiting' do
      subject.update(al_visiting: false)
      subject.update(al_visiting_date: Date.parse('15.05.2011'))
      expect(camp_visiting_info(subject.al_visiting, subject.al_visiting_date)).to eq('Besucht das Lager nicht')
    end

  end


  context '#format_event_canton' do

    it 'returns canton full name' do
      camp = events(:schekka_camp)
      camp.update(canton: 'so')
      expect(format_event_canton(camp)).to eq 'Solothurn'
    end

    it 'returns ausland' do
      camp = events(:schekka_camp)
      camp.update(canton: Event::Camp::ABROAD_CANTON)
      expect(format_event_canton(camp)).to eq 'Ausland'
    end

  end

  context '#labeled_camp_days' do
    subject { events(:schekka_camp) }
    it 'shows camp days like labeled attr' do
      expect(labeled_camp_days(subject)).to have_css('dt', text: 'Anzahl Lagertage')
      expect(labeled_camp_days(subject)).to have_css('dd', text: '8')
    end
  end

end
