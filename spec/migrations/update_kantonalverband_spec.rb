# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe UpdateKantonalverband do

  let(:al) { people(:al_berchtold) }
  let(:migration) { UpdateKantonalverband.new }

  it 'updates kantonalverband for all people' do
    al.update!({kantonalverband: nil})
    require 'pry'; binding.pry unless $pstop

    migration.up

    expect(al.reload.kantonalverband_id).to eq(groups(:be).id)
  end
end
