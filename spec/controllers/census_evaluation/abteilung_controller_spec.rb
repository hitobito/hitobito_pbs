# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusEvaluation::AbteilungController do

  let(:abteilung) { groups(:schekka) }

  before { sign_in(people(:bulei)) }

  describe 'GET total' do

    before { get :index, id: abteilung.id }

    it 'assigns counts' do
      expect(assigns(:group_counts)).to be_blank
    end

    it 'assigns total' do
      total = assigns(:total)
      expect(total).to be_kind_of(MemberCount)
      expect(total.total).to eq(12)
    end

    it 'assigns sub groups' do
      expect(assigns(:sub_groups)).to be_blank
    end

  end

end
