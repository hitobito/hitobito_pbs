#  Copyright (c) 2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs

require "spec_helper"

describe SubscriptionsController do
  let(:user) { people(:al_schekka) }
  let(:group) { groups(:schekka) }
  let(:event) { Fabricate(:event, groups: [group], dates: [Fabricate(:event_date, start_at: Time.zone.today)]) }
  let(:mailing_list) { Fabricate(:mailing_list, group: group) }

  before { sign_in(user) }

  it "renders csv in backround job" do
    expect do
      get :index, params: {group_id: group.id, mailing_list_id: mailing_list.id}, format: :csv
      expect(flash[:notice]).to match(
        /Export wird im Hintergrund gestartet und kann nach Fertigstellung auf der Jobübersicht/
      )
      expect(response).to redirect_to(returning: true)
    end.to change(Delayed::Job, :count).by(1)
  end

  it "renders xlsx in backround job" do
    expect do
      get :index, params: {group_id: group.id, mailing_list_id: mailing_list.id}, format: :xlsx
      expect(flash[:notice]).to match(
        /Export wird im Hintergrund gestartet und kann nach Fertigstellung auf der Jobübersicht/
      )
      expect(response).to redirect_to(returning: true)
    end.to change(Delayed::Job, :count).by(1)
  end
end
