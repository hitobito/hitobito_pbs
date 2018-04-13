# encoding: utf-8

#  Copyright (c) 2016 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplicationLabelHelper

    attr_reader :pdf, :data

    delegate :text, :table, to: :pdf
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

    def with_label(key, value)
      label = t('export/pdf/camp_application.' + key)
      labeled_value(label, value)
    end

    def labeled_value(label, value)
      cells = [[label, value.to_s]]
      cell_style = { border_width: 0, padding: 0 }
      table(cells, cell_style: cell_style, column_widths: [180, 300]) do
        column(0).style font_style: :italic
      end
    end

    def labeled_email(person)
      value = person.email
      return unless value.present?
      label = t('events.fields_pbs.email')
      labeled_value(label, value)
    end

    def labeled_phone_number(person, phone_label)
      value = data.phone_number(person, phone_label)
      return unless value.present?
      label = t("events.fields_pbs.phone_#{phone_label.downcase}")
      labeled_value(label, value)
    end

    def labeled_checkpoint_attr(attr)
      label = data.t_camp_attr(attr.to_s)
      value = data.camp_attr_value(attr)
      text "#{label}: #{value}"
    end

  end
end
