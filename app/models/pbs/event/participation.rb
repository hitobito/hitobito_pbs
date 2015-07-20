# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::Participation
  extend ActiveSupport::Concern

  included do
    class_attribute :possible_states

    # states are used for workflow
    # translations in config/locales
    self.possible_states = %w(tentative applied assigned rejected canceled attended absent)

    ACTIVE_STATES = %w(assigned attended)

    # Define methods to query if a participation is in the given state.
    # eg participation.canceled?
    possible_states.each do |state|
      define_method "#{state}?" do
        self.state == state
      end
    end

    ### SCOPES

    scope :tentative, -> { where(state: 'tentative') }
    scope :countable_applicants, -> { where(state: %w(applied assigned attended absent)) }

    ### VALIDATIONS

    validates :state, inclusion: possible_states, if: :course?
    validates :canceled_at, presence: true, if: :canceled?

    ### CALLBACKS

    before_validation :set_default_state, if: :course?
    before_validation :delete_tentatives, if: :course?, unless: :tentative?, on: :create
    before_validation :set_active_based_on_state, if: :course?
    before_validation :clear_canceled_at, unless: :canceled?
  end

  def course?
    event.instance_of?(Event::Course)
  end

  private

  def set_default_state
    self.state ||= 'applied'
  end

  # custom join event belongs_to kind is not defined in core
  def delete_tentatives
    Event::Participation.
      tentative.
      joins('INNER JOIN events ON events.id = event_participations.event_id').
      joins('INNER JOIN event_kinds ON event_kinds.id = events.kind_id').
      where(events: { kind_id: event.kind_id }, person_id: person.id).
      destroy_all
  end

  def set_active_based_on_state
    self.active = ACTIVE_STATES.include?(state)
    true
  end

  def clear_canceled_at
    self.canceled_at = nil
    true
  end

end
