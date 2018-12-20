#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: black_lists
#
#  id                     :integer          not null, primary key
#  first_name             :string
#  last_name              :string
#  pbs_number             :string
#  email                  :string
#  phone_number           :string
#  reference_name         :string
#  reference_phone_number :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'spec_helper'

describe BlackList do

  describe 'to_s' do
    subject { Fabricate(:black_list).to_s }

    it { is_expected.to eq('Schwarze Liste') }
  end

end
