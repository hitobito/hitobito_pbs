# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Role::TypeList do

  it 'contains all groups for top layer' do
    list = Role::TypeList.new(Group::Bund)
    all_groups = list.to_enum.collect do |layer, groups|
      [layer, groups.keys]
    end

    expect(all_groups).to eq([
      ['Bund', ['Bund', 'Gremium']],
      ['Kantonalverband', ['Kantonalverband', 'Gremium']],
      ['Region', ['Region', 'Rover', 'Gremium']],
      ['Abteilung', ['Abteilung', 'Biber', 'Wölfe', 'Pfadi', 'Pio',
                     'Rover', 'PTA', 'Elternrat', 'Gremium']],
    ])
  end

end
