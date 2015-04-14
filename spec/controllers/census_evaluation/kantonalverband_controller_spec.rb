# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusEvaluation::KantonalverbandController do

  let(:ch)   { groups(:bund) }
  let(:be)   { groups(:be) }
  let(:schekka)   { groups(:schekka) }
  let(:berchtold) { groups(:berchtold) }
  let(:patria)    { groups(:patria) }

  before { sign_in(people(:bulei)) }

  describe 'GET index' do
    before { get :index, id: be.id }

    it 'assigns counts' do
      counts = assigns(:group_counts)
      expect(counts.keys).to match_array([schekka.id, berchtold.id])
      expect(counts[schekka.id].total).to eq(12)
      expect(counts[berchtold.id].total).to eq(7)
    end

    it 'assigns total' do
      expect(assigns(:total)).to be_kind_of(MemberCount)
    end

    it 'assigns sub groups' do
      expect(assigns(:sub_groups)).to eq([berchtold, patria, schekka, groups(:schweizerstern)])
    end
  end

end
