# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


# == Schema Information
#
# Table name: censuses
#
#  id        :integer          not null, primary key
#  year      :integer          not null
#  start_at  :date
#  finish_at :date
#

require 'spec_helper'

describe Census do

  describe '.last' do
    subject { Census.last }

    it { should == censuses(:two_o_12) }
  end

  describe '.current' do
    subject { Census.current }

    it { should == censuses(:two_o_12) }
  end
end
