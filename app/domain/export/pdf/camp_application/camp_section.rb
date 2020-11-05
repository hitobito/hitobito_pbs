# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    class CampSection < BaseSection
      def render
        bounding_box([0, cursor], width: bounds.width) do
          title('title')
          bounding_box([0, cursor], width: bounds.width) do
            SplitBox.render(@document) do |box|
              box.left { render_dates }
              box.right { render_locations }
            end
          end
        end
      end

      def render_dates
        text translate('camp_dates'), style: :bold
        move_down 3
        @context.camp.dates.each do |date| 
          labeled_value(date.duration.to_s, date.label, { column_widths: [95, nil]} ) 
        end
        move_down 10
        labeled_camp_attr(:camp_days)
      end

      def render_locations
        text translate('camp_location'), style: :bold
        move_down 3
        labeled_camp_attr(:canton)
        labeled_camp_attr(:location)
        labeled_camp_attr(:coordinates)
        labeled_camp_attr(:altitude)
        labeled_camp_attr(:emergency_phone)
        labeled_camp_attr(:landlord)
        move_down 10
        labeled_checkpoint(:landlord_permission_obtained)
      end
    end
  end
end
