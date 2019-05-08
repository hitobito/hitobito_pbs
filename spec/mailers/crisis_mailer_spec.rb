# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CrisisMailer do
  include ActiveSupport::Testing::TimeHelpers

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  let(:crisis) { crises(:bulei_bund) }
  let(:bund)   { groups(:bund) }
  let(:date)   { '2019-05-08 09:57:00' }
  let(:link)   { %{<a href="http://test.host/groups/#{bund.id}">Pfadibewegung Schweiz</a>} }

  before do
    @leiter = Fabricate(Group::Bund::LeitungKernaufgabeKommunikation.name.to_sym, group: bund).person
    @verantwortlich = Fabricate(Group::Bund::VerantwortungKrisenteam.name.to_sym, group: bund).person
  end

  context 'triggered' do
    let(:mail) { CrisisMailer.triggered(crisis) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Krise wurde eingeleitet' }
      its(:from)    { should eq ['noreply@localhost'] }
      its(:to)      { should match_array [@leiter.email, @verantwortlich.email] }
    end

    context 'body' do
      subject { mail.body }
      it 'renders placeholders' do
        travel_to date do
          is_expected.to match(/Dr. Bundes Leiter hat am 08.05.2019 09:57/)
          is_expected.to match(/eine Krise in der Gruppe #{link} eingeleitet/)
        end
      end
    end
  end

  context 'acknowledged' do
    let(:person) { people(:bulei) }
    let(:mail)   { CrisisMailer.acknowledged(crisis, person) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Krise wurde quittiert' }
      its(:to)      { should match_array [@leiter.email, @verantwortlich.email] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        travel_to date do
          is_expected.to match(/Die von Dr. Bundes Leiter am 08.05.2019 09:57/)
          is_expected.to match(/in der Gruppe #{link} eingeleitet Krise/)
          is_expected.to match(/wurde von Dr. Bundes Leiter quittiert/)
        end
      end
    end
  end

end
