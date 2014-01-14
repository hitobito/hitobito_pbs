# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe MemberCountsController, type: :controller do

  render_views

  let(:abteilung) { groups(:schekka) }

  before { sign_in(people(:bulei)) }

  describe 'GET edit' do
    before { get :edit, group_id: abteilung.id, year: 2012 }

    it 'should render template' do
      should render_template('edit')
    end
  end

end
