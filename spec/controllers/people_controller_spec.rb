# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PeopleController do
  let(:json) { JSON.parse(response.body) }

  context "GET query_tentative" do
    it "returns people as typeahead" do
      sign_in(people(:al_schekka))

      get :query_tentative, q: 'Child', format: :js
      expect(json).to have(1).item
      expect(json.first['label']).to eq 'My Child'
    end

    it "only finds people for which user may update" do
      sign_in(people(:bulei))

      get :query_tentative, q: 'Child', format: :js
      expect(json).to be_empty
    end
  end

end
