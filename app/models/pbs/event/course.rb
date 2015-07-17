# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Course
  extend ActiveSupport::Concern

  included do
    LANGUAGES = %w(de fr it en)
    APPROVALS = %w(requires_approval_abteilung requires_approval_region
                   requires_approval_kantonalverband requires_approval_bund)

    LANGUAGES.each { |key| used_attributes << "language_#{key}".to_sym }
    APPROVALS.each { |key| used_attributes << key.to_sym }
    self.used_attributes += [:express_fee, :tentative_applications]
    self.used_attributes -= [:requires_approval]

    # states are used for workflow
    # translations in config/locales
    self.possible_states = %w(created confirmed application_open application_closed
                              assignment_closed canceled completed closed)

    # Define methods to query if a course is in the given state.
    # eg course.canceled?
    possible_states.each do |state|
      define_method "#{state}?" do
        self.state == state
      end
    end

    class_attribute :superior_attributes
    self.superior_attributes = [:express_fee, :training_days]


    ### VALIDATIONS

    validates :state, inclusion: possible_states


    ### CALLBACKS
    before_save :set_requires_approval

    alias_method_chain :count_applicants_scope, :tentative
  end


  # may participants apply now?
  def application_possible?
    application_open? &&
    (!application_opening_at || application_opening_at <= ::Date.today) &&
    (!application_closing_at || application_closing_at > ::Date.today)
  end

  def qualification_possible?
    !completed? && !closed?
  end

  def state
    super || possible_states.first
  end

  def tentative_application_possible?
    tentative_applications? && %w(created confirmed).include?(state)
  end

  def tentatives_count
    participations.tentative.count
  end

  # participations can be created form members of these groups
  def tentative_group_ids
    groups.flat_map { |g| g.self_and_descendants.pluck(:id) + g.hierarchy.pluck(:id) }
  end

  private

  module ClassMethods
    def application_possible
      where(state: 'application_open').
      where('events.application_opening_at IS NULL OR events.application_opening_at <= ?',
            ::Date.today)
    end
  end

  def set_requires_approval
    self.requires_approval =
      requires_approval_abteilung? ||
      requires_approval_region? ||
      requires_approval_kantonalverband? ||
      requires_approval_bund?

    true
  end

  def count_applicants_scope_with_tentative
    count_applicants_scope_without_tentative.countable
  end

end
