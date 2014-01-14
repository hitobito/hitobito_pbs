# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe CensusEvaluation::KantonalverbandController, type: :controller do

  render_views

  let(:ch)   { groups(:bund) }
  let(:be)   { groups(:be) }
  let(:schekka) { groups(:schekka) }
  let(:berchtold) { groups(:berchtold) }

  before { sign_in(people(:bulei)) }

  describe 'GET total' do
    before { get :index, id: be.id }

    it 'renders correct templates' do
      should render_template('index')
      should render_template('_totals')
    end
  end

end
