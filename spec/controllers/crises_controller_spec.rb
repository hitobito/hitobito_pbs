#  Copyright (c) 2018 Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe CrisesController do

  let(:user) { role.person }
  let(:role) { Fabricate(Group::Bund::MitgliedKrisenteam.name.to_sym, group: groups(:bund)) }


  before do
    @ref = @request.env['HTTP_REFERER'] = root_path
  end

  describe 'authorized' do
    before do
      sign_in(user)
    end

    context 'create' do
      it 'create crisis send mail and set crisis session' do
        groups(:be).crises.destroy_all

        expect do
          post :create, group_id: groups(:be)
        end.to change { ActionMailer::Base.deliveries.count }.by 1

        crisis = user.crises.last

        expect(session[:crisis]).to be true
        expect(crisis.group).to eq(group)
        expect(crisis.acknowledged?).to be false
        expect(last_email.subject).to match(/Krise wurde ausgelöst/)
        expect(last_email.body).to match(/Auf der Abteilung test wurde eine Krise durch/)
        expect(last_email.body).to match(/das Krisenteam der Bundesebene ausgelöst/)
      end

      it 'shows error if another crisis is active' do
        expect do
          post :create, group_id: groups(:be)
        end.to change { ActionMailer::Base.deliveries.count }.by 0

        expect(session[:crisis]).to be nil
        expect(flash[:alert]).to eq('Eine andere Krise ist bereits aktiv auf dieser Gruppe')
      end
    end

    context 'acknowledge' do
      it 'acknowledges crisis if not older then 3 days' do
        expect do
          post :acknowledge, group_id: groups(:be), crisis_id: crises(:al_schekka_be)
        end.to change { ActionMailer::Base.deliveries.count }.by 1

        expect(crises(:al_schekka_be).acknowledged).to be true
        expect(last_email.subject).to match(/Krise wurde quittiert/)
        expect(last_email.body).to match(/Die von al_schekka eröffnete Krise in der Gruppe Bern/)
        expect(last_email.body).to match(/wurde von /)
      end

      it 'does not acknowledge if crisis older then 3 days' do
        crises(:al_schekka_be).update(created_at: 4.days.ago)
        expect do
          post :acknowledge, group_id: groups(:be), crisis_id: crises(:al_schekka_be)
        end.to change { ActionMailer::Base.deliveries.count }.by 0

        expect(crises(:al_schekka_be).acknowledged).to be false
        expect(flash[:alert]).to eq('Die Krise ist zu alt um zu quittieren')
      end
    end
  end
end
