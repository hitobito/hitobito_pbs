#  Copyright (c) 2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.
#
require "spec_helper"

describe SearchStrategies::GroupSearch do
  before do
    groups(:bund).update!(pbs_shortname: "shortname", description: "description", website: "lemurenshop",
      bank_account: "account")
  end

  describe "#search_fulltext" do
    let(:user) { people(:root) }

    it "finds accessible groups by shortname" do
      result = search_class(groups(:bund).pbs_shortname).search_fulltext
      expect(result).to include(groups(:bund))
    end

    it "finds accessible groups by description" do
      result = search_class(groups(:bund).description).search_fulltext
      expect(result).to include(groups(:bund))
    end

    it "finds accessible groups by website" do
      result = search_class(groups(:bund).website).search_fulltext
      expect(result).to include(groups(:bund))
    end

    it "finds accessible groups by bank account" do
      result = search_class(groups(:bund).bank_account).search_fulltext
      expect(result).to include(groups(:bund))
    end
  end

  def search_class(term = nil, page = nil)
    described_class.new(user, term, page)
  end
end
