# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'
require_relative 'subgroups_shared_examples'

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
      assigns(:sub_groups).should == [berchtold, schekka]
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

    it 'redirects abteilung leaders' do
      sign_in(people(:al_schekka))
      expect do
        expect { post :remind, id: be.id, abteilung_id: schekka.id, format: :js }.to raise_error(CanCan::AccessDenied)
      end.not_to change { Delayed::Job.count }
    end
  end

  it_behaves_like 'sub_groups' do
    let(:parent)              { be }
    let(:census)              { censuses(:two_o_12) }
    let(:subgroups)           { [schekka, patria, berchtold] }
    let(:group_to_delete)     { schekka }
    let(:group_without_count) { patria }

    before { groups(:schweizerstern).destroy }

    context 'moving group' do
      let(:target) { be }
      let(:chaeib)  { groups(:chaeib) }

      before do
        member_counts(:chaeib).destroy
        Fabricate(:member_count, year: census.year - 1, abteilung: schekka, kantonalverband: be)
        Fabricate(:member_count, year: census.year - 1, abteilung: berchtold, kantonalverband: be)
        Fabricate(:member_count, year: census.year - 1, abteilung: chaeib, kantonalverband: groups(:zh))
        Group::Mover.new(chaeib).perform(target).should be_true
        Fabricate(:member_count, year: census.year, abteilung: chaeib, kantonalverband: target)
      end

      context 'new parent' do
        include_examples 'sub_groups_examples' do
          let(:before_deadline) { subgroups + [chaeib] }
          let(:after_deadline)  { subgroups + [chaeib] - [group_without_count] } # count written for old group
          let(:next_year)    { subgroups + [chaeib] }
        end

        context 'last year' do
          before { get :index, id: parent.id, year: census.year - 1 }
          it     { should eq (subgroups - [group_without_count]).sort_by(&:name) }
        end
      end

      context 'old parent' do
        let(:parent)          { groups(:zh) }

        include_examples 'sub_groups_examples' do
          let(:before_deadline) { [] }
          let(:after_deadline)  { [] }
          let(:next_year)    { [] }
        end

        context 'last year' do
          before { get :index, id: parent.id, year: census.year - 1 }
          it     { should eq [chaeib].sort_by(&:name) }
        end
      end
    end
  end
end
