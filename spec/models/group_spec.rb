# encoding: utf-8

#  Copyright (c) 2012-2013, Puzzle ITC GmbH. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

require 'spec_helper'

describe Group do
  include_examples 'group types'


  describe "#all_types" do
    subject { Group.all_types }

    it "must have simple group as last item" do
      subject.last.should == Group::Gremium
    end

  end


end
