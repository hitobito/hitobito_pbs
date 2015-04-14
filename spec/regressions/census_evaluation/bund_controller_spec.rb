# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusEvaluation::BundController, type: :controller do

  render_views

  let(:ch)   { groups(:bund) }
  let(:zh)   { Fabricate(Group::Kantonalverband.name, name: 'Zurich', parent: ch) }

  before do
    zh # create
    sign_in(people(:bulei))
  end

  describe 'GET total' do
    context 'as admin' do
      before { get :index, id: ch.id }

      it 'renders correct templates' do
        is_expected.to render_template('index')
        is_expected.to render_template('_totals')
      end
    end

    context 'as normal user' do
      before { sign_in(people(:al_schekka)) }
      before { get :index, id: ch.id }

      it 'renders correct templates' do
        is_expected.to render_template('index')
        is_expected.to render_template('_totals')
      end
    end
  end

end
