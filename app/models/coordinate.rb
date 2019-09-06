#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: group_coordinates
#
#  id                     :integer          not null, primary key
#  lat                    :string
#  long                   :string
#  group_id               :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Coordinate < ActiveRecord::Base

  self.table_name = :group_coordinates

  belongs_to :group

  validates_by_schema

  def to_s
    "(#{lat}, #{long})"
  end

end
