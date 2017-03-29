# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe GroupsController do

  include CrudControllerTestHelper

  let(:entry) { assigns(:group) }

  context 'PUT update cantons' do

    let(:user) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person }

    describe_action :put, :update, id: true do
      let(:test_entry) { groups(:be) }

      context 'with multiple cantons' do
        let(:params) { { group: { cantons: %w(be bs zh) } } }

        it 'updates cantons' do
          test_entry.update!(cantons: %w(be ge))
          expect { perform_request }.to change { KantonalverbandCanton.count }.by(1)
          expect(assigns(:group).cantons).to eq %w(be bs zh)
        end
      end

      context 'with no cantons' do
        let(:params) { { group: { cantons: [''] } } }

        it 'removes cantons' do
          test_entry.update!(cantons: %w(be ge))
          expect { perform_request }.to change { KantonalverbandCanton.count }.by(-2)
          expect(assigns(:group).cantons).to eq []
        end
      end
    end

  end

  context 'update superior attributes as kantonsleitung' do

    let(:user) { Fabricate(Group::Kantonalverband::Kantonsleitung.name.to_sym, group: groups(:be)).person }

    context 'for kanton' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:be) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change' do
          perform_request
          expect(assigns(:group).vkp).to be_falsey
        end
      end
    end

    context 'for abteilung' do
      describe_action :put, :update, id: true do
        let(:test_entry) { groups(:schekka) }
        let(:params) { { group: { bank_account: 'CH123', vkp: true, pta: false } } }

        it 'cannot change' do
          perform_request
          expect(assigns(:group).vkp).to be_falsey
        end
      end
    end
  end

end
