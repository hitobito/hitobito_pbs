# encoding: utf-8

#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    class LeadersSection < BaseSection
      def render
        bounding_box([0, cursor], width: bounds.width) do
          title('title')
          next text(I18n.t('global.nobody')) unless leaders.any?

          table(table_data.unshift(table_header), width: bounds.width,
                      cell_style: { border_width: 0.25, size: 8 },
                      column_widths: [190, 55, nil]) do 
                            row(0).style(font_style: :bold)
                      end
        end
      end

      protected 

      def leaders 
        @context.camp_assistant_leaders
      end

      def table_data
        table_data = leaders.collect do |person|
          [person.to_s, person.birthday.try(:year).to_s, @context.active_qualifications(person)]
        end
      end

      def table_header
        name = translate('assistant_leader_name')
        year = translate('assistant_leader_year')
        qualifications = translate('assistant_leader_qualifications')
        [name, year, qualifications]
      end
    end
  end
end
