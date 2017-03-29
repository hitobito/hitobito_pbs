# encoding: utf-8

#  Copyright (c) 2012-2017, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Course

  extend ActiveSupport::Concern

  LANGUAGES = %w(de fr it en).freeze
  APPROVALS = %w(requires_approval_abteilung requires_approval_region
                 requires_approval_kantonalverband requires_approval_bund).freeze

  included do
    include Event::RestrictedRole

    self.used_attributes += [:advisor_id, :express_fee, :bsv_days] +
                            LANGUAGES.collect { |key| "language_#{key}".to_sym } +
                            APPROVALS.collect(&:to_sym)
    self.used_attributes -= [:requires_approval]

    self.superior_attributes = [:express_fee, :training_days]


    self.role_types = [Event::Course::Role::Leader,
                       Event::Course::Role::ClassLeader,
                       Event::Role::Speaker,
                       Event::Course::Role::Helper,
                       Event::Role::Cook,
                       Event::Course::Role::Participant]

    restricted_role :advisor, Event::Course::Role::Advisor


    validates :number, presence: true
    validates :bsv_days, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    validate :assert_bsv_days_precision

    ### CALLBACKS
    before_save :set_requires_approval
  end


  # may participants apply now?
  def application_possible?
    application_open? &&
    (!application_opening_at || application_opening_at <= ::Time.zone.today) &&
    (!application_closing_at || application_closing_at > ::Time.zone.today)
  end

  private

  def set_requires_approval
    self.requires_approval =
      requires_approval_abteilung? ||
      requires_approval_region? ||
      requires_approval_kantonalverband? ||
      requires_approval_bund?

    true
  end

  def assert_bsv_days_precision
    if bsv_days && bsv_days % 0.5 != 0
      msg = I18n.t('activerecord.errors.messages.must_be_multiple_of', multiple: 0.5)
      errors.add(:bsv_days, msg)
    end
  end

end
