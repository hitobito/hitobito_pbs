# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    class RegistrationSection < BaseSection
      def render
        bounding_box([0, cursor], width: bounds.width) do
          SplitBox.render(@document) do |box|
            box.left { render_js }
            box.right { render_state }
          end
        end
      end

      def render_js
        title('js_title')
        labeled_camp_attr(:j_s_kind)
        return unless @context.camp.j_s_kind.present?

        labeled_value(translate('js_security'), @context.js_security_value)
        move_down 6
        labeled_camp_attr(:advisor_mountain_security)
        labeled_camp_attr(:advisor_water_security)
        labeled_camp_attr(:advisor_snow_security)
      end

      def render_state
        title('state_title')
        labeled_camp_attr(:updated_at)
        labeled_camp_attr(:state)
      end
    end
  end
end
