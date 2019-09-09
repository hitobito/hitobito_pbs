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

  context 'PUT change geolocations of Abteilung' do
    describe_action :put, :update, id: true do

      let(:user) { Fabricate(Group::Abteilung::Abteilungsleitung.name.to_sym, group: groups(:patria)).person }

      let(:test_entry) { groups(:patria) }

      context 'adding geolocations' do
        let(:params) { {group: {geolocations_attributes: [
          {lat: 'lat1', long: 'long1', _destroy: 'false'},
          {lat: '2 123 123', long: '1 123 123', _destroy: 'false'},
        ]}} }

        it 'adds geolocations' do
          expect { perform_request }.to change { test_entry.reload.geolocations.count }.by(2)
        end

        it 'refuses to add too many geolocations' do
          (Group::Abteilung::GEOLOCATION_COUNT_LIMIT - 1).times do
            Fabricate(Geolocation.name.downcase.to_sym, geolocatable: test_entry)
          end
          expect { perform_request }.not_to change { test_entry.reload.geolocations.count }
          expect(assigns(:group).errors.size).to eq(1)
        end
      end

      context 'adding and simultaneously removing geolocations' do
        before do
          (Group::Abteilung::GEOLOCATION_COUNT_LIMIT - 1).times do
            Fabricate(Geolocation.name.downcase.to_sym, geolocatable: test_entry)
          end
        end

        let(:params) { {group: {geolocations_attributes: [
          {id: Geolocation.last.id, lat: 'lat1', long: 'long1', _destroy: 1},
          {lat: 'lat1', long: 'long1', _destroy: 'false'},
          {lat: '2 123 123', long: '1 123 123', _destroy: 'false'},
        ]}} }

        it 'allows to add more geolocations than allowed if removing others' do
          expect { perform_request }.to change { test_entry.reload.geolocations.count }.by(1)
        end
      end

      context 'removing geolocations' do
        let!(:geolocation1) { Fabricate(Geolocation.name.downcase.to_sym, geolocatable: test_entry) }
        let!(:geolocation2) { Fabricate(Geolocation.name.downcase.to_sym, geolocatable: test_entry) }
        let!(:geolocation3) { Fabricate(Geolocation.name.downcase.to_sym, geolocatable: test_entry) }
        let(:params) { {group: {geolocations_attributes: [
          {id: geolocation1.id.to_s, lat: 'lat1', long: 'long1', _destroy: 1},
          {id: geolocation2.id.to_s, lat: '2 123 123', long: '1 123 123', _destroy: 1},
        ]}} }

        it 'removes geolocations' do
          expect(test_entry.reload.geolocations.count).to eq(3)
          expect { perform_request }.to change { test_entry.reload.geolocations.count }.by(-2)
        end
      end

    end
  end

end
