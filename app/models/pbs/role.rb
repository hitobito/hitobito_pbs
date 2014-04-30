# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.


# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  group_id   :integer          not null
#  type       :string(255)      not null
#  label      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#
module Pbs::Role
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:created_at, :deleted_at]

    validates :created_at,
              timeliness: { type: :datetime,
                            on_or_before: :now,
                            allow_blank: true }
    validates :deleted_at,
              timeliness: { type: :datetime,
                            on_or_before: :now,
                            after: ->(role) { role.created_at },
                            allow_blank: true }
  end

  def created_at=(value)
    super(value)
  rescue ArgumentError
    # could not set value
    super(nil)
  end

  def deleted_at=(value)
    super(value)
  rescue ArgumentError
    # could not set value
    super(nil)
  end
end
