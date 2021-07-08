#  Copyright (c) 2020 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe GroupHealthController do

  let(:user) { people(:root) }
  let(:token) { ServiceToken.create(name: 'Token', layer: groups(:bund)) }

  describe 'authentication' do
    it 'redirects to login' do
      get :people
      is_expected.to redirect_to '/users/sign_in'
    end
  end

  describe 'unauthorized' do
    before { sign_in(people(:bulei)) }

    it 'denies access' do
      expect { get :people }.to raise_error(CanCan::AccessDenied)
    end

  end

  describe 'service-token' do
    before do
      token.update(group_health: true)
    end

    it 'is authorized' do
      request.headers['X-Token'] = token.token
      get :groups, format: :json
      expect(response).to have_http_status(200)
    end
  end

  describe 'authorized' do
    before { sign_in(user) }

    describe 'GET show' do
      context 'json' do

        it 'is valid' do
          get :groups, format: :json
          json = JSON.parse(response.body)
          group = json['groups'].first
          expect(group['name']).to eq(groups(:bund).name)
        end
      end

      context 'no opt-in' do
        it 'does not export any people' do
          get :people, format: :json
          json = JSON.parse(response.body)
          expect(json['people'].size).to eq(0)
        end

        it 'does not export any courses' do
          get :courses, format: :json
          json = JSON.parse(response.body)
          expect(json['courses'].size).to eq(0)
        end

        it 'does only export groups of type Bund and Kantonalverband' do
          get :groups, format: :json
          json = JSON.parse(response.body)
          expect(json['groups'].size).to eq(4)
          types = json['groups'].map {|g| g['type']}.uniq
          expect(types).to eq(['Group::Bund', 'Group::Kantonalverband'])
        end
      end

      context 'opt-in' do
        before do
          groups(:schekka).update(group_health: true)
        end

        it 'does export the group having opted in' do
          get :groups, format: :json
          json = JSON.parse(response.body)
          groups = json['groups'].select {|g| g['name'] == groups(:schekka).name}
          expect(groups.size).to eq(1)
        end

        it 'exports geolocations' do
          location = Fabricate(:geolocation, geolocatable: groups(:schekka))
          get :groups, format: :json
          json = JSON.parse(response.body)
          groups = json['groups'].select {|g| g['name'] == groups(:schekka).name}
          expect(groups[0]['geolocations']).to eq([{ 'id' => location.id, 'lat' => location.lat, 'long' => location.long }])
        end

        it 'does only export people with roles in a group having opted in' do
          get :people, format: :json
          json = JSON.parse(response.body)
          expect(json['people'].size).to eq(2)
        end

        it 'does only export camps with participants having roles in a group having opted in' do
          get :camps, format: :json
          json = JSON.parse(response.body)
          expect(json['camps'].size).to eq(1)
          expect(json['camps'][0]['name']).to eq(events(:schekka_camp).name)
        end

        it 'does paginate' do
          Role.create(group: groups(:schekka), person: people(:bulei),
                      type: Group::Abteilung::Sekretariat.sti_name)
          get :participations, params: { size: 3 }, format: :json
          json = JSON.parse(response.body)
          expect(json['participations'].size).to eq(3)
          get :participations, params: { page: 2, size: 3 }, format: :json
          json = JSON.parse(response.body)
          expect(json['participations'].size).to eq(2)
        end
      end
    end

  end

end
