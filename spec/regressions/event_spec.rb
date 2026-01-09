#  Copyright (c) 2012-2026, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Event do
  context "duplicating nested camps works" do
    it "should duplicate nested camp" do
      super_camp = Event::Camp.find_by(name: "Tsueri Super")
      camp = Event::Camp.create!(name: "Testcamp", super_camp:, dates: super_camp.dates, groups: super_camp.groups)
      expect(camp.lft > super_camp.lft)
      duplicate_camp = camp.duplicate.tap do |dup|
        dup.dates = camp.dates
      end
      duplicate_camp.save!
      expect(duplicate_camp.parent_id).to be_nil
    end
  end
end
