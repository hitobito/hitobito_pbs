# frozen_string_literal: true

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Event do
  subject { Fabricate(:event, groups: [groups(:be)]) }

  it 'is not globally_visible' do
    is_expected.to_not be_globally_visible
  end
end
