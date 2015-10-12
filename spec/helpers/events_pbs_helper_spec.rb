# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe EventsPbsHelper do

  context '#expected_participants_value_present?' do

    subject { events(:schekka_camp) }

    it 'returns true if at least one value present' do
      subject.update_attributes(expected_participants_pio_f: 3)
      expect(expected_participants_value_present?(subject)).to be true
    end

    it 'returns false if no value present' do
      expect(expected_participants_value_present?(subject)).to be false
    end

  end

end
