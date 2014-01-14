# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require_relative 'subgroups_shared_examples'

describe CensusEvaluation::BundController do

  let(:ch)   { groups(:bund) }
  let(:be)   { groups(:be) }
  let(:vd)   { groups(:vd) }
  let(:zh)   { groups(:zh) }

  before { sign_in(people(:bulei)) }

  describe 'GET total' do
    before { Date.stub(today: censuses(:two_o_12).finish_at) }

    before { get :index, id: ch.id }

    it 'assigns counts' do
      counts = assigns(:group_counts)
      counts.keys.should =~ [be.id, zh.id]
      counts[be.id].total.should == 19
      counts[zh.id].total.should == 9
    end

    it 'assigns total' do
      assigns(:total).should be_kind_of(MemberCount)
    end

    it 'assigns sub groups' do
      assigns(:sub_groups).should == [be, vd, zh]
    end

    it 'assigns abteilungen' do
      assigns(:abteilungen).should == {
        be.id => { confirmed: 2, total: 4 },
        vd.id => { confirmed: 0, total: 0 },
        zh.id => { confirmed: 1, total: 1 },
      }.with_indifferent_access
    end

    it 'assigns year' do
      assigns(:year).should == Census.last.year
    end
  end


  it_behaves_like 'sub_groups' do
    let(:parent)              { ch }
    let(:census)              { censuses(:two_o_12) }
    let(:subgroups)           { [be, vd, zh] }
    let(:group_to_delete)     { be }
    let(:group_without_count) { vd }
  end
end
