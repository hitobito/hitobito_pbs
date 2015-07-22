# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationFilter

  extend ActiveSupport::Concern

  included do
    self.load_entries_includes += [:application]

    alias_method_chain :predefined_filters, :revoked
    alias_method_chain :apply_filter_scope, :revoked
  end

  def predefined_filters_with_revoked
    @predefined_filters ||=
      predefined_filters_without_revoked.dup.tap do |predefined|
        if event.supports_applications? &&
           Ability.new(user).can?(:index_revoked_participations, event)
          predefined << 'revoked'
        end
      end
  end

  private

  def apply_filter_scope_with_revoked(records, kind = params[:filter])
    if kind == 'revoked' && predefined_filters.include?('revoked')
      event.participations.
            joins(:roles).
            where('event_roles.type' => event.participant_types.collect(&:sti_name)).
            where('event_participations.state' => Pbs::Event::Participation::REVOKED_STATES).
            includes(load_entries_includes).
            uniq
    else
      apply_filter_scope_without_revoked(records, kind)
    end
  end

end
