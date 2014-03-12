module Pbs::Role
  extend ActiveSupport::Concern

  included do
    self.used_attributes += [:created_at, :deleted_at]

    validates :created_at, :deleted_at, timeliness: { type: :datetime, on_or_before: :now, allow_blank: true }
    validates :deleted_at, timeliness: { after: ->(role) { role.created_at }, allow_blank: true }
  end
end

