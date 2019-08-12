#  Copyright (c) 2018 Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe CrisesController do

  let(:user)  { Fabricate(Group::Bund::MitgliedKrisenteam.name.to_sym, group: groups(:bund)).person }
  let(:group) { groups(:chaeib) }

  describe 'authorized' do
    before { sign_in(user) }

    context 'POST#create' do
      it 'creates crisis send mail and set crisis session' do
        expect do
          post :create, group_id: group.id
        end.to change { Delayed::Job.count }.by 1

        expect(session[:crisis]).to be true
        expect(group.active_crisis).not_to be_acknowledged
      end

      it 'shows error if another crisis is active' do
        group.crises.create!(creator: user)
        expect do
          post :create, group_id: group.id
        end.not_to change { Delayed::Job.count }

        expect(session[:crisis]).to be nil
        expect(flash[:alert]).to eq('Eine andere Krise ist bereits aktiv auf dieser Gruppe')
      end
    end

    context 'PUT#update' do
      before do
        group.crises.create!(creator: user)
      end
      it 'acknowledges crisis if not older then 3 days' do
        expect do
          put :update, group_id: group.id, id: group.active_crisis.id
        end.to change { Delayed::Job.count }.by 1

        expect(group.active_crisis.reload).to be_acknowledged
      end

      it 'does not acknowledge if crisis older then 3 days' do
        group.active_crisis.update(created_at: 4.days.ago)
        expect do
          put :update, group_id: group.id, id: group.active_crisis.id

        end.not_to change { Delayed::Job.count }

        expect(group.active_crisis.reload).not_to be_acknowledged
        expect(flash[:alert]).to eq('Die Krise ist zu alt um zu quittieren')
      end
    end
  end
end
