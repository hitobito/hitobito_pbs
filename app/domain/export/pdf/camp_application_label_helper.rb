# encoding: utf-8

#  Copyright (c) 2016 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplicationLabelHelper

    attr_reader :pdf, :data

    delegate :text, :formatted_text, :table, :font_size, :cursor, :move_cursor_to, :bounding_box,
      :bounds, :stroke_bounds, :new_page, to: :pdf
    delegate :t, to: I18n

    def initialize(pdf, data)
      @pdf = pdf
      @data = data
    end

    def labeled_camp_attr(attr, show_blank = false)
      value = data.camp_attr_value(attr)
      return unless value.present? || show_blank
      label = data.t_camp_attr(attr.to_s)
      value = show_blank unless value.present?
      labeled_value(label, value)
    end

    def with_label(key, value, options = {})
      label = t('export/pdf/camp_application.' + key)
      labeled_value(label, value, options)
    end

    def labeled_value(label, value, options = {})
      cell_style = { border_width: 0, padding: 1 }.merge(options.delete(:cell_style) || {})
      options = { cell_style: cell_style, column_widths: [97, 143] }.merge(options)
      cells = [[label, value.to_s]]
      table(cells, options) do
        column(0).style font_style: :italic
        column(1).style overflow: :shrink_to_fit, min_font_size: 6
      end
    end

    def labeled_email(person, options = {})
      value = person.email
      return unless value.present?
      label = t('events.fields_pbs.email')
      labeled_value(label, value, { cell_style: { height: 12 } }.merge(options))
    end

    def labeled_phone_number(person, phone_label, options = {})
      value = data.phone_number(person, phone_label)
      return unless value.present?
      label = t("events.fields_pbs.phone_#{phone_label.downcase}")
      labeled_value(label, value, options)
    end

    def labeled_checkpoint_attr(attr)
      label = data.t_camp_attr(attr.to_s)
      value = data.camp_attr_value(attr)
      font_size 8 do
        text "#{label}: <b>#{value}</b>", inline_format: true
      end
    end

    def in_columns(columns = [], height = nil, initial_cursor: cursor, gap: 20, width: 500)
      column_width = width / columns.count - (gap / 2)
      bounding_box [0, initial_cursor], width: width, height: height do
        cursors = columns.each_with_index.map do |column, index|
          bounding_box [index * (column_width + gap), bounds.top], width: column_width do
            column.call
          end
          cursor
        end
        move_cursor_to cursors.min
      end
    end
  end
end
