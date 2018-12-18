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

  let(:person)     { Fabricate(:person, first_name: 'foo', last_name: 'bar') }
  let(:group)      { groups(:schekka) }
  let(:event)      { events(:top_course) }

  let!(:gl_role)   { Fabricate(Group::Bund::Geschaeftsleitung.name.to_sym, group: groups(:bund)) }
  let!(:lkk_role)  { Fabricate(Group::Bund::LeitungKernaufgabeKommunikation.name.to_sym,
                               group: groups(:bund)) }

  let(:group_mail) { BlackListMailer.group_hit(person, group) }
  let(:event_mail) { BlackListMailer.event_hit(person, event) }

  context 'group mail headers' do
    subject { group_mail }
    its(:subject) { should eq 'Treffer auf Schwarzer Liste' }
    its(:to)      { should include gl_role.person.email }
    its(:to)      { should include lkk_role.person.email }
    its(:from)    { should eq ['noreply@localhost'] }
  end

  context 'event mail headers' do
    subject { event_mail }
    its(:subject) { should eq 'Treffer auf Schwarzer Liste' }
    its(:to)      { should include gl_role.person.email }
    its(:to)      { should include lkk_role.person.email }
    its(:from)    { should eq ['noreply@localhost'] }
  end

  context 'group body' do
    subject { group_mail.body }

    it 'renders placeholders' do
      is_expected.to match(/Die Person <a href="/)
      is_expected.to match(/foo bar<\/a>/)
      is_expected.to match(/Schekka<\/a>/)
    end
  end

  context 'event body' do
    subject { event_mail.body }

    it 'renders placeholders' do
      is_expected.to match(/Die Person <a href="/)
      is_expected.to match(/foo bar<\/a>/)
      is_expected.to match(/Top Course<\/a>/)
    end
  end

end
