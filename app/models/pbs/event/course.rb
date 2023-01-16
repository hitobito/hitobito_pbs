# encoding: utf-8

#  Copyright (c) 2012-2021, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Course

  extend ActiveSupport::Concern

  LANGUAGES = %w(de fr it en).freeze
  APPROVALS = %w(requires_approval_abteilung requires_approval_region
                 requires_approval_kantonalverband requires_approval_bund).freeze

  included do
    include Pbs::Event::RestrictedRole

    self.used_attributes += [:advisor_id, :express_fee, :bsv_days, :has_confirmations] +
                            LANGUAGES.collect { |key| "language_#{key}".to_sym } +
                            APPROVALS.collect(&:to_sym)
    self.used_attributes -= [:requires_approval, :j_s_kind, :canton, :camp_submitted,
                             :camp_submitted_at, :total_expected_leading_participants,
                             :total_expected_participants, :globally_visible]

    self.superior_attributes = [:express_fee, :training_days]


    self.role_types = [Event::Course::Role::Leader,
                       Event::Course::Role::ClassLeader,
                       Event::Role::Speaker,
                       Event::Course::Role::Helper,
                       Event::Role::Cook,
                       Event::Course::Role::Participant]

    self.supports_invitations = false

    restricted_role :advisor, Event::Course::Role::Advisor


    validates :number, presence: true
    validates :bsv_days, numericality: { greater_than_or_equal_to: 0, allow_blank: true }
    validate :assert_bsv_days_precision

    ### CALLBACKS
    after_initialize :become_campy
    before_save :set_requires_approval
    before_save :set_globally_visible
    after_save :request_missing_approvals
  end


  # may participants apply now?
  def application_possible?
    application_open? &&
    (!application_opening_at || application_opening_at <= ::Time.zone.today) &&
    (!application_closing_at || application_closing_at >= ::Time.zone.today)
  end

  module ClassMethods
    def campy_kind?(kind_id)
      now = Time.zone.now.to_i
      if (now - @campy_ids_updated_at.to_i) > 15
        @campy_ids = Event::Kind.where(campy: true).pluck(:id)
        @campy_ids_updated_at = now
      end
      @campy_ids.include?(kind_id)
    end
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

  def set_globally_visible
    self.globally_visible = true
  end

  def request_missing_approvals
    if APPROVALS.any? { |approval_attr| saved_change_to_attribute? approval_attr.to_sym }
      participations.each do |participation|
        Event::Approver.new(participation).request_approvals
      end
    end
  end

  def assert_bsv_days_precision
    if bsv_days && bsv_days % 0.5 != 0
      msg = I18n.t('activerecord.errors.messages.must_be_multiple_of', multiple: 0.5)
      errors.add(:bsv_days, msg)
    end
  end

  def become_campy
    if campy?
      singleton_class.restricted_roles = self.class.restricted_roles.except(:advisor)
      singleton_class.role_types -= [Event::Course::Role::Advisor]
      singleton_class.used_attributes -= [:advisor_id]

      # Wheee, we are just about to extend a SINGLE INSTANCE with the Campy module.
      # Only do this when no other possibilities exist!
      extend Event::Campy
      extend Campy
    end
  end

  def campy?
    if association(:kind).loaded?
      kind && kind.campy?
    else
      self.class.campy_kind?(kind_id)
    end
  end

  module Campy
    def advisor
      coach
    end

    def advisor_id
      coach_id
    end
  end

end
