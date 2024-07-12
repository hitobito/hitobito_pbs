#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Crisis < ActiveRecord::Base
  belongs_to :group
  belongs_to :creator, class_name: "Person"

  scope :active, -> {
                   where("created_at > ? OR acknowledged = ? AND created_at > ?",
                     3.days.ago, true, 1.week.ago)
                 }

  validate :no_active_crisis_on_group

  validates_by_schema

  private

  def no_active_crisis_on_group
    if Crisis.active.where(group: group).where.not(id: self).present?
      errors.add(:base, I18n.t("activerecord.errors.models.crisis.another_active"))
    end
  end
end
