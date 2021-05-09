# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    class SupervisionSection < BaseSection
      def render
        bounding_box([0, cursor], width: bounds.width) do
          SplitBox.render(@document) do |box|
            box.left { render_abteilungsleitung }
            box.right { render_coach }
          end
        end
      end

      def render_abteilungsleitung
        title('abteilungsleitung_title')
        abteilungsleitung = @context.camp.abteilungsleitung
        labeled_person(abteilungsleitung, false) if abteilungsleitung
        move_down 9
        labeled_checkpoint(:al_present)
        labeled_checkpoint(:al_visiting)
      end

      def render_coach
        title('coach_title')
        coach = @context.camp.coach
        labeled_person(coach, false) if coach
        move_down 9
        labeled_checkpoint(:coach_visiting)
      end
    end
  end
end
