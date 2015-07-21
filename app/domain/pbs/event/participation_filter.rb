# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ParticipationFilter

  extend ActiveSupport::Concern

  REVOKED_STATES =

  included do
    Event::ParticipationFilter::PREDEFINED_FILTERS << 'revoked'

    self.load_entries_includes += [:application]

    alias_method_chain :apply_filter_scope, :revoked
  end

  def apply_filter_scope_with_revoked(records, kind = params[:filter])
    if kind == 'revoked'
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
