#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe SearchStrategies::PersonSearch do
  before do
    people(:al_schekka).update!(pbs_number: 4566, title: "Sky")
  end

  describe "#search_fulltext" do
    let(:user) { people(:bulei) }

    it "finds accessible person by title" do
      result = search_class(people(:al_schekka).title).search_fulltext
      expect(result).to include(people(:al_schekka))
    end

    it "finds accessible person by pbs number" do
      result = search_class(people(:al_schekka).pbs_number.to_s).search_fulltext
      expect(result).to include(people(:al_schekka))
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end
