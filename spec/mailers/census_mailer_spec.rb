# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusMailer do

  before do
    SeedFu.quiet = true
    SeedFu.seed [HitobitoPbs::Wagon.root.join('db', 'seeds')]
  end

  let(:person) { people(:bulei) }
  let(:census) { censuses(:two_o_12) }

  subject { mail }

  describe '#reminder' do
    let(:leaders) do
      [Fabricate.build(:person, email: 'test@example.com', first_name: 'firsty'),
       Fabricate.build(:person, email: 'test2@example.com', first_name: 'lasty')]
    end

    context 'with contact address' do
      let(:mail) { CensusMailer.reminder(people(:bulei).email, census, leaders, groups(:schekka), groups(:be)) }

      its(:subject)   { should == 'Bestandesmeldung ausfüllen!' }
      its(:to)        { should == ['test@example.com', 'test2@example.com'] }
      its(:reply_to)  { should == [people(:bulei).email] }
      its(:sender)    { should =~ /#{people(:bulei).email.gsub('@', '=')}/ }
      its(:body)      { should =~ /Hallo firsty, lasty/ }
      its(:body)      { should =~ /Klostergasse 3<br\/>3333 Bern<br\/>bern@be.ch/ }
      its(:body)      { should =~ /bis am 31\.10\.2012/ }
    end
  end
end
