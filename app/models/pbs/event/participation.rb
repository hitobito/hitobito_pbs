# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Participation

  extend ActiveSupport::Concern

  included do
    validates :bsv_days, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    validate :assert_bsv_days_precision
  end

  def approvers
    Person.where(id: application && application.approvals.collect(&:approver_id))
  end

  private

  def assert_bsv_days_precision
    if bsv_days && bsv_days % 0.5 != 0
      msg = I18n.t('activerecord.errors.messages.must_be_multiple_of', multiple: 0.5)
      errors.add(:bsv_days, msg)
    end
  end

end
