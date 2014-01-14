# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusReminderJob do

  before do
    SeedFu.quiet = true
    SeedFu.seed [HitobitoPbs::Wagon.root.join('db', 'seeds')]
  end

  before do
    abteilung.roles.where(type: Group::Abteilung::Abteilungsleitung.sti_name).destroy_all
  end

  let(:abteilung) { groups(:schekka) }
  let(:leaders) do
    all = []
    all << Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung, person: Fabricate(:person, email: 'test1@example.com')).person
    all << Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung, person: Fabricate(:person, email: 'test2@example.com')).person
    # empty email
    all << Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung, person: Fabricate(:person, email: ' ')).person
    all
  end

  subject { CensusReminderJob.new(people(:bulei), Census.current, abteilung) }


  describe '#recipients' do

    it 'contains all abteilung leaders with emails' do
      leaders

      # different roles
      Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be))
      Fabricate(Group::Pfadi::Einheitsleitung.name.to_sym, group: groups(:pegasus))
      Fabricate(Group::Abteilung::StufenleitungPfadi.name.to_sym, group: abteilung)

      subject.recipients.should =~ leaders[0..1]
    end
  end

  describe '#perform' do
    it 'sends email if abteilung has leaders' do
      leaders
      expect { subject.perform }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'does not send email if abteilung has no leaders' do
      expect { subject.perform }.not_to change { ActionMailer::Base.deliveries.size }
    end

    it 'does not send email if leader has no email' do
      Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung, person: Fabricate(:person, email: '  ')).person
      expect { subject.perform }.not_to change { ActionMailer::Base.deliveries.size }
    end

    it 'finds kalei address' do
      leaders
      subject.perform
      last_email.body.should =~ /Klostergasse 3<br\/>3333 Bern/
    end

    it 'sends only to leaders with email' do
      leaders
      subject.perform
      last_email.to.should == [leaders.first.email, leaders.second.email]
    end
  end

end
