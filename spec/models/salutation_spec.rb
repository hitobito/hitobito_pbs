# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Salutation do

  let(:person)     { people(:bulei) }
  let(:salutation) { Salutation.new(person) }

  context '.available' do
    subject { Salutation.available }

    it { expect(subject).to have(4).items }
  end

  context '#label' do
    subject { salutation.label }

    it { expect(subject).to eq('Sehr geehrte(r) Frau/Herr [Titel] [Nachname]') }
  end

  context '#value' do
    subject { salutation.value }

    context 'without title' do
      before { person.title = nil }
      it { expect(subject).to eq('Sehr geehrter Herr Leiter') }
    end

    context 'with title' do
      it { expect(subject).to eq('Sehr geehrter Herr Dr. Leiter') }
    end

    context 'female' do
      before { person.gender = 'w' }
      it { expect(subject).to eq('Sehr geehrte Frau Dr. Leiter') }
    end

    context 'no gender' do
      before { person.gender = nil }
      it { expect(subject).to eq('Sehr geehrte(r) Dr. Leiter') }
    end

    context 'empty gender' do
      before { person.gender = '' }
      it { expect(subject).to eq('Sehr geehrte(r) Dr. Leiter') }
    end

    context 'without salutation' do
      before { person.salutation = nil }
      it { expect(subject).to eq('Hallo Bundes') }
    end

    context 'lieber pfadiname' do
      before { person.salutation = 'lieber_pfadiname' }
      it { expect(subject).to eq('Lieber Scout') }
    end

    context 'lieber vorname' do
      before { person.salutation = 'lieber_vorname' }
      it { expect(subject).to eq('Lieber Bundes') }
    end

    context 'lieber titel nachname' do
      before { person.salutation = 'lieber_titel_nachname' }
      it { expect(subject).to eq('Lieber Herr Dr. Leiter') }
    end

    context 'lieber nachname' do
      before do
        person.salutation = 'lieber_titel_nachname'
        person.title = ' '
      end
      it { expect(subject).to eq('Lieber Herr Leiter') }
    end

    context 'sehr geehrter nachname' do
      before { person.salutation = 'sehr_geehrter_titel_nachname' }
      it { expect(subject).to eq('Sehr geehrter Herr Dr. Leiter') }
    end
  end

end
