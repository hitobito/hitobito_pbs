# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PopulationController do

  let(:abteilung) { groups(:schekka) }
  let(:pegasus) { groups(:pegasus) }


  let!(:leader) { Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: abteilung).person }
  let!(:guide) { Fabricate(Group::Abteilung::StufenleitungWoelfe.name.to_sym, group: abteilung).person }
  let!(:webmaster) { Fabricate(Group::Abteilung::Webmaster.name.to_sym, group: abteilung).person }
  let!(:deleted) do
    Fabricate(Group::Abteilung::AbteilungsleitungStv.name.to_sym,
              group: abteilung,
              created_at: 2.years.ago,
              deleted_at: 1.year.ago)
  end
  let!(:group_leader) { Fabricate(Group::Pfadi::Mitleitung.name.to_sym, group: pegasus, person: guide).person }
  let!(:child) { Fabricate(Group::Pfadi::Pfadi.name.to_sym, group: pegasus).person }

  before { sign_in(leader) }

  describe 'GET index' do
    before { get :index, id: abteilung.id }

    describe 'groups' do
      subject { assigns(:groups) }

      it do
        should == [abteilung,
                   groups(:sunnewirbu),
                   groups(:pegasus),
                   groups(:poseidon),
                   groups(:medusa),
                   groups(:baereried),
                   groups(:rovers),
                   groups(:elternrat),
                   groups(:fussballers)]
      end
    end

    describe 'people by group' do
      subject { assigns(:people_by_group) }

      it { subject[abteilung].collect(&:to_s).should =~ [leader, people(:al_schekka), guide].collect(&:to_s) }
      it { subject[groups(:pegasus)].collect(&:to_s).should =~ [group_leader, child, people(:child)].collect(&:to_s) }
      it { subject[groups(:baereried)].should be_nil } # no people in group - not displayed at all
    end

    describe 'complete' do
      subject { assigns(:people_data_complete) }

      it { should be_false }
    end
  end

  describe 'GET index does not include deleted groups' do
    before do
      groups(:poseidon).destroy
      get :index, id: abteilung.id
    end

    subject { assigns(:groups) }

    it { should_not include groups(:poseidon) }
  end
end
