# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Dropdown
  module Event
    class CampParticipantStatus < Dropdown::Base

      attr_reader :group, :event, :participation

      def initialize(template, group, event, participation)
        super(template, translate(:change_state), 'flag')
        @group = group
        @event = event
        @participation = participation
        init_items
      end

      private

      def init_items
        possible_states.each do |state|
          label = label_for_state(state)
          if participation.state == state
            add_item(content_tag(:strong, label), nil)
          else
            add_item(label, link_for_state(state), data: { method: :patch })
          end
        end
      end

      def link_for_state(state)
        template.group_event_participation_path(group,
                                                event,
                                                participation,
                                                event_participation: { state: state })
      end

      def label_for_state(state)
        I18n.t("activerecord.attributes.event/camp.participation_states.#{state}")
      end

      def possible_states
        states = event.possible_participation_states
        unless event.paper_application_required?
          states -= ['applied_electronically']
        end
        states
      end

    end
  end
end
