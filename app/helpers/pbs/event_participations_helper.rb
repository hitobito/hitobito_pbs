#  Copyright (c) 2012-2024, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module EventParticipationsHelper
    def show_js_data_sharing_option?(participation)
      participation.j_s_data_sharing_acceptance_required?
    end

    def js_data_sharing_help_text(participation, for_someone_else)
      base_key_self =
        ::Pbs::Event::ParticipationsController::CONTENT_KEY_JS_DATA_SHARING_INFO_SELF
      base_key_other =
        ::Pbs::Event::ParticipationsController::CONTENT_KEY_JS_DATA_SHARING_INFO_OTHER
      base_key = for_someone_else ? base_key_other : base_key_self
      content_key = "#{base_key}-#{participation.event.type}"

      CustomContent.get(content_key).body
    end

    def event_participation_table_options(t, event)
      if @event.is_a?(Event::Camp)
        table.col(Event::Participation.human_attribute_name(:state)) 		 { |p| t("activerecord.attributes.event/camp.participation_states.#{p.state}") }
      end
    end
  end
end
