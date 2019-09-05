#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# == Schema Information
#
# Table name: coordinates
#
#  id                     :integer          not null, primary key
#  lat                    :string
#  lng                    :string
#  group_id               :integer          not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Coordinate < ActiveRecord::Base

  COUNT_LIMIT = 4

  validates_by_schema

  validate :assert_count_limit, on: :create

  def assert_count_limit
    return unless self.group
    if self.group.coordinates(:reload).count >= COUNT_LIMIT
      errors.add(:base, :too_many_coordinates)
    end
  end

  def to_s
    self.class.model_name.human
  end

end
