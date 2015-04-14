# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusEvaluation::BundController do

  let(:ch)   { groups(:bund) }
  let(:be)   { groups(:be) }
  let(:vd)   { groups(:vd) }
  let(:zh)   { groups(:zh) }

  before { sign_in(people(:bulei)) }

  describe 'GET index' do
    before { allow(Date).to receive_messages(today: censuses(:two_o_12).finish_at) }
    before { groups(:schweizerstern).destroy }

    before { get :index, id: ch.id }

    it 'assigns counts' do
      counts = assigns(:group_counts)
      expect(counts.keys).to match_array([be.id, zh.id])
      expect(counts[be.id].total).to eq(19)
      expect(counts[zh.id].total).to eq(9)
    end

    it 'assigns total' do
      expect(assigns(:total)).to be_kind_of(MemberCount)
    end

    it 'assigns sub groups' do
      expect(assigns(:sub_groups)).to eq([be, vd, zh])
    end

    it 'assigns abteilungen' do
      expect(assigns(:abteilungen)).to eq(
        be.id => { confirmed: 2, total: 3 },
        vd.id => { confirmed: 0, total: 0 },
        zh.id => { confirmed: 1, total: 1 }
      )
    end

    it 'assigns year' do
      expect(assigns(:year)).to eq(Census.last.year)
    end
  end

end
