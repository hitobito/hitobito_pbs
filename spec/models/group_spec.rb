# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: groups
#
#  id                     :integer          not null, primary key
#  parent_id              :integer
#  lft                    :integer
#  rgt                    :integer
#  name                   :string(255)      not null
#  short_name             :string(31)
#  type                   :string(255)      not null
#  email                  :string(255)
#  address                :string(1024)
#  zip_code               :integer
#  town                   :string(255)
#  country                :string(255)
#  contact_id             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  layer_group_id         :integer
#  creator_id             :integer
#  updater_id             :integer
#  deleter_id             :integer
#  pta                    :boolean          default(FALSE), not null
#  vkp                    :boolean          default(FALSE), not null
#  pbs_material_insurance :boolean          default(FALSE), not null
#  website                :string(255)
#  pbs_shortname          :string(15)
#  bank_account           :string(255)
#  description            :text
#


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
