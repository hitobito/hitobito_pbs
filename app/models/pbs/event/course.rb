# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Course
  extend ActiveSupport::Concern

  LANGUAGES = %w(de fr it en)
  APPROVALS = %w(requires_approval_abteilung requires_approval_region
                 requires_approval_kantonalverband requires_approval_bund)

  included do
    include Event::RestrictedRole

    self.used_attributes += [:advisor_id, :express_fee, :tentative_applications] +
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

    ### VALIDATIONS

    validates :state, inclusion: possible_states


    ### CALLBACKS
    before_save :set_requires_approval

    alias_method_chain :applicants_scope, :tentative
  end


  # may participants apply now?
  def application_possible?
    application_open? &&
    (!application_opening_at || application_opening_at <= ::Date.today) &&
    (!application_closing_at || application_closing_at > ::Date.today)
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

  def organizers
    Person.
      includes(:roles).
      where(roles: { type: organizing_role_types,
                     group_id: groups.collect(&:id) })
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

  def applicants_scope_with_tentative
    applicants_scope_without_tentative.countable_applicants
  end

  def organizing_role_types
    ::Role.types_with_permission(:layer_full) + ::Role.types_with_permission(:layer_and_below_full)
  end

end
