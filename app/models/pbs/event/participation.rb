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

    # Define methods to query if a course is in the given state.
    # eg course.canceled?
    possible_states.each do |state|
      define_method "#{state}?" do
        self.state == state
      end
    end


    ### VALIDATIONS

    validates :state, inclusion: possible_states, if: -> { event.instance_of?(Event::Course) }
  end

end
