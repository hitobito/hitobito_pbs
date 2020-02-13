#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

RSpec.describe SubcampsController, type: :controller do

  let(:supercamp) { events(:bund_supercamp) }

  before do
    sign_in(people(:al_schekka))
  end

  describe "GET #index" do
    render_views

    it "returns http success" do
      get :index, params: { group_id: supercamp.groups.first, event_id: supercamp }
      expect(response).to have_http_status(:success)
    end
  end

end
