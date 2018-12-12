# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CrisisMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [Rails.root.join('db', 'seeds')]
  end

  context 'completed' do
    let(:crisis) { crises(:bulei_bund) }
    let(:mail) { CrisisMailer.completed(crisis) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Krise quittiert' }
      its(:to)      { should eq [groups(:bund).email] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Die von Dr. Bundes Leiter eröffnete Krise/)
        is_expected.to match(/in der Gruppe Pfadibewegung Schweiz wurde soeben quittiert/)
      end
    end
  end

  context 'incompleted' do
    let(:crisis) { crises(:bulei_bund) }
    let(:mail) { CrisisMailer.incompleted(crisis) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Krise wurde nicht quittiert' }
      its(:to)      { should eq [groups(:bund).email] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Dr. Bundes Leiter hat vor zwei Wochen/)
        is_expected.to match(/in der Gruppe Pfadibewegung Schweiz/)
      end
    end
  end

  context 'triggered' do
    let(:crisis) { crises(:bulei_bund) }
    let(:mail) { CrisisMailer.triggered(crisis) }

    context 'headers' do
      subject { mail }
      its(:subject) { should eq 'Krise wurde eingeleitet' }
      its(:to)      { should eq [groups(:bund).email] }
      its(:from)    { should eq ['noreply@localhost'] }
    end

    context 'body' do
      subject { mail.body }

      it 'renders placeholders' do
        is_expected.to match(/Dr. Bundes Leiter hat gerade eine Krise/)
        is_expected.to match(/in der Gruppe Pfadibewegung Schweiz eingeleitet./)
      end
    end
  end

end
