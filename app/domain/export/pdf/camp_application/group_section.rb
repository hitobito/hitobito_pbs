#  Copyright (c) 2015 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    class GroupSection < BaseSection
      def render
        bounding_box([0, cursor], width: bounds.width) do
          SplitBox.render(@document) do |box|
            box.left { render_group }
            box.right { render_leader }
          end
        end
      end

      def render_group
        title("group_title")
        labeled_value(translate("abteilung"), @context.abteilung_name)
        labeled_value(translate("einheit"), @context.einheit_name) if @context.einheit_name
        labeled_value(translate("kantonalverband"), kantonalverband) if kantonalverband
        move_down 12
        text translate("expected_participants")
        move_down 9
        table(table_data, cell_style: {align: :center, border_width: 0.25},
          column_widths: [30, 40, 40, 40, 40, 40]) do
          row(0).style(size: 6)
        end
      end

      def render_leader
        title("leader_title")
        leader = @context.camp_leader
        if leader
          labeled_person(leader)
          labeled_value(translate("qualifications"), @context.active_qualifications(leader))
        else
          text(I18n.t("global.nobody")) unless leader
        end
        move_down 9
        render_checkpoints
      end

      def render_checkpoints
        Event::Camp::LEADER_CHECKPOINT_ATTRS.each do |attr|
          labeled_checkpoint(attr)
        end
      end

      protected

      def kantonalverband
        @context.kantonalverband
      end

      def table_data
        [@context.expected_participant_table_header,
          @context.expected_participant_table_row(:f),
          @context.expected_participant_table_row(:m)]
      end
    end
  end
end
