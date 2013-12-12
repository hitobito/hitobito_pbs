# encoding: utf-8

#  Copyright (c) 2012-2013, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Group do
  include_examples 'group types'


  describe "#all_types" do
    subject { Group.all_types }

    it "must have simple group as last item" do
      expect(subject.last).to eq(Group::Gremium)
    end

    it 'is in hierarchical order' do
      expect(subject.collect(&:name)).to eq(
        [Group::Bund,
         Group::Kantonalverband,
         Group::Region,
         Group::Abteilung,
         Group::Biber,
         Group::Woelfe,
         Group::Pfadi,
         Group::Pio,
         Group::Rover,
         Group::Pta,
         Group::Elternrat,
         Group::Gremium].collect(&:name))
    end
  end


end
