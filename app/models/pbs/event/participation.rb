#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Participation
  extend ActiveSupport::Concern

  included do
    validates :bsv_days, numericality: {greater_than_or_equal_to: 0, allow_blank: true}
    validates :j_s_data_sharing_accepted, presence: true, if: :j_s_data_sharing_acceptance_required?
    validate :assert_bsv_days_precision
    validate :assert_bsv_days_set
    after_create :send_black_list_mail, if: :person_blacklisted?

    delegate :j_s_data_sharing_acceptance_required?, to: :event
  end

  def approvers
    Person.where(id: application&.approvals&.collect(&:approver_id))
  end

  def j_s_data_sharing_accepted
    j_s_data_sharing_accepted_at.present?
  end
  alias_method :j_s_data_sharing_accepted?, :j_s_data_sharing_accepted

  def j_s_data_sharing_accepted=(value)
    accepted = ActiveModel::Type::Boolean.new.cast(value) || false
    return if j_s_data_sharing_accepted_at? || !accepted

    self.j_s_data_sharing_accepted_at = Time.zone.now
  end

  private

  def send_black_list_mail
    BlackListMailer.hit(person, event).deliver_now
  end

  def assert_bsv_days_precision
    if bsv_days && bsv_days % 0.5 != 0
      msg = I18n.t("activerecord.errors.messages.must_be_multiple_of", multiple: 0.5)
      errors.add(:bsv_days, msg)
    end
  end

  def assert_bsv_days_set
    if event.try(:bsv_days).present? && %w[attended].include?(state) && bsv_days.blank?
      msg = I18n.t("activerecord.errors.messages.must_exist")
      errors.add(:bsv_days, msg)
    end
  end

  def person_blacklisted?
    person.black_listed?
  end
end
