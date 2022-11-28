# encoding: utf-8

#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Participation

  extend ActiveSupport::Concern

  included do
    validates :bsv_days, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    validate :assert_bsv_days_precision
    validate :assert_bsv_days_set
    after_create :send_black_list_mail, if: :person_blacklisted?

    alias_method_chain :send_confirmation, :pbs
  end

  def approvers
    Person.where(id: application && application.approvals.collect(&:approver_id))
  end

  private

  def send_black_list_mail
    BlackListMailer.hit(person, event).deliver_now
  end

  def assert_bsv_days_precision
    if bsv_days && bsv_days % 0.5 != 0
      msg = I18n.t('activerecord.errors.messages.must_be_multiple_of', multiple: 0.5)
      errors.add(:bsv_days, msg)
    end
  end

  def assert_bsv_days_set
    if event.try(:bsv_days).present? && %w[attended].include?(state) && bsv_days.blank?
      msg = I18n.t('activerecord.errors.messages.must_exist')
      errors.add(:bsv_days, msg)
    end
  end

  def person_blacklisted?
    person.black_listed?
  end

  # disable core's confirmation since
  # pbs wagon has customized participation notifications
  def send_confirmation_with_pbs; end
end
