# frozen_string_literal: true

#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require "spec_helper"

describe Household do
  let(:main) { Fabricate(:person_with_address, prefers_digital_correspondence: true) }
  let(:other) { Fabricate(:person_with_address, prefers_digital_correspondence: false) }

  it "sets pbs attributes when updating household" do
    household = described_class.new(main)
    household.add(other)
    expect(household.save).to eq true
    expect(other.reload.street).to eq main.street
    expect(other.reload.prefers_digital_correspondence).to eq true
  end
end
