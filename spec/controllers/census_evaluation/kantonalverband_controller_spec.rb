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

    context 'when moving group' do
      let(:target) { be }
      let(:chaeib) { groups(:chaeib) }

      context 'before count' do
        before do
          Group::Mover.new(chaeib).perform(target).should be_true
        end

        context 'in new parent' do
          before { member_counts(:chaeib).destroy }

          include_examples 'sub_groups_examples' do
            let(:current_census_groups) { subgroups + [chaeib] }
            let(:past_census_groups)    { subgroups - [group_without_count] }
            let(:future_census_groups)  { subgroups + [chaeib] }
          end
        end

        context 'in old parent' do
          let(:parent) { groups(:zh) }

          context '' do
            before { member_counts(:chaeib).destroy }
            include_examples 'sub_groups_examples' do

              let(:current_census_groups) { [] }
              let(:past_census_groups)    { [] } # empty for spec implementation reasons, tested in example below
              let(:future_census_groups)  { [] }
            end
          end

          context 'for past census' do
            subject { assigns(:sub_groups).collect(&:name) }
            it 'contains moved group' do
               Census.create!(year: census.year + 1,
                              start_at: census.start_at + 1.year)
               get :index, id: parent.id, year: census.year
               should eq [chaeib].collect(&:name).sort
            end
          end
        end

      end

      context 'after count' do
        before do
          Group::Mover.new(chaeib).perform(target).should be_true
        end

        context 'in new parent' do
          include_examples 'sub_groups_examples' do
            let(:current_census_groups) { subgroups }
            let(:past_census_groups)    { subgroups - [group_without_count] }
            let(:future_census_groups)  { subgroups + [chaeib] }
          end
        end

        context 'in old parent' do
          let(:parent)          { groups(:zh) }

          include_examples 'sub_groups_examples' do
            let(:current_census_groups) { [chaeib] }
            let(:past_census_groups)    { [chaeib] }
            let(:future_census_groups)  { [] }
          end
        end
      end
    end
  end
end
