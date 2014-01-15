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
      counts.keys.should =~ [schekka.id, berchtold.id]
      counts[schekka.id].total.should == 12
      counts[berchtold.id].total.should == 7
    end

    it 'assigns total' do
      assigns(:total).should be_kind_of(MemberCount)
    end

    it 'assigns sub groups' do
      assigns(:sub_groups).should == [berchtold, patria, schekka, groups(:schweizerstern)]
    end
  end

  describe 'POST remind' do
    it 'creates mail job' do
      expect { post :remind, id: be.id, abteilung_id: schekka.id, format: :js }.to change { Delayed::Job.count }.by(1)
    end

    context '.js' do
      before { post :remind, id: be.id, abteilung_id: schekka.id, format: :js }

      it 'renders update_flash' do
        should render_template('census_evaluation/kantonalverband/remind')
      end

      it 'sets flash messages' do
        flash[:notice].should =~ /an Schekka geschickt/
      end
    end

    context '.html' do
      before { post :remind, id: be.id, abteilung_id: schekka.id }

      it 'redirects to index' do
        should redirect_to(census_kantonalverband_group_path(be))
      end
    end

    it 'redirects abteilung leaders' do
      sign_in(people(:al_schekka))
      expect do
        expect { post :remind, id: be.id, abteilung_id: schekka.id, format: :js }.to raise_error(CanCan::AccessDenied)
      end.not_to change { Delayed::Job.count }
    end
  end

end
