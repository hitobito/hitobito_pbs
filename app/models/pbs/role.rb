# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Role
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:created_at, :deleted_at]

    validates :created_at, :deleted_at,
              timeliness: { type: :datetime,
                            on_or_before: :now,
                            allow_blank: true }
    validates :deleted_at,
              timeliness: { after: ->(role) { role.created_at },
                            allow_blank: true }
  end
end
