# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe BlackListMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  let(:person)     { people(:al_schekka) }
  let(:person_url) { "http://test.host/people/#{person.id}" }

  let(:group)      { groups(:schekka) }
  let(:event)      { events(:top_course) }


  let!(:gl_role)   { Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)) }
  let!(:lkk_role)  { Fabricate(Group::Bund::LeitungKernaufgabeKommunikation.name.to_sym,
                               group: groups(:bund)) }

  %w(group event).each do |target|
    context 'headers' do
      subject { BlackListMailer.hit(person, send(target)) }

      its(:subject) { should eq 'Treffer auf Schwarzer Liste' }
      its(:to)      { should include gl_role.person.email }
      its(:to)      { should include lkk_role.person.email }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { BlackListMailer.hit(person, send(target)).body }

      it 'renders placeholders' do
        expect(subject).to match(%r{Die Person <a href="#{person_url}">AL Schekka</a>})
        expect(subject).to match(%r{wurde bei <a href="#{url(send(target))}">#{send(target)}</a> hinzugefügt})
      end
    end

    def url(target)
      "http://test.host/#{target.model_name.route_key}/#{target.id}"
    end
  end

  context 'person' do
    let(:person_mail) { BlackListMailer.hit(person) }

    context 'headers' do
      subject { person_mail }

      its(:subject) { should eq 'Treffer auf Schwarzer Liste' }
      its(:to)      { should include gl_role.person.email }
      its(:to)      { should include lkk_role.person.email }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { BlackListMailer.hit(person).body }

      it 'renders placeholders' do
        expect(subject).to match(%r{Die Person <a href="#{person_url}">AL Schekka</a> wurde aktualisiert})
      end
    end
  end
end
