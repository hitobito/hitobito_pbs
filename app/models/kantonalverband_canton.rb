# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


# == Schema Information
#
# Table name: kantonalverband_cantons
#
#  id                 :integer          not null, primary key
#  kantonalverband_id :integer          not null
#  canton             :string(2)        not null
#

class KantonalverbandCanton < ActiveRecord::Base

  belongs_to :kantonalverband, class_name: 'Group::Kantonalverband'

  validates_by_schema
  validates :canton, inclusion: Cantons.short_name_strings

  def to_s
    canton.upcase
  end

end
