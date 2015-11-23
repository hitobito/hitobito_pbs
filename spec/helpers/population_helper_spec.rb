# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe PopulationHelper do

  context '#age' do

    before do
      allow(Time).to receive_message_chain(:zone, :now).and_return(DateTime.new(2014, 6, 10))
    end

    it 'accepts nil' do
      expect(helper.age(nil)).to eq('-')
    end

    it 'accepts future birthyear' do
      expect(helper.age(2016)).to eq('-')
    end

    it 'calculates correct age #1' do
      expect(helper.age(2014)).to eq(0)
    end

    it 'calculates correct age #2' do
      expect(helper.age(2000)).to eq(14)
    end
  end

end
