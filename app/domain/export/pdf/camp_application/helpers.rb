#  Copyright (c) 2016 Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Export::Pdf
  class CampApplication
    module Helpers
      def labeled_camp_attr(attr, show_blank = false)
        value = @context.camp_attr_value(attr)
        return unless value.present? || show_blank

        label = @context.t_camp_attr(attr.to_s)
        value = show_blank if value.blank?
        labeled_value(label, value)
      end

      def labeled_checkpoint(attr)
        label = @context.t_camp_attr(attr.to_s)
        value = @context.camp_attr_value(attr)
        text "#{label}: <b>#{value}</b>", inline_format: true, size: 8
      end

      def labeled_value(label, value, options = {})
        cell_style = {border_width: 0, padding: 1}.merge(options.delete(:cell_style) || {})
        options = {cell_style: cell_style, column_widths: [95, 135]}.merge(options)
        cells = [[label, value.to_s]]
        table(cells, options) do
          column(0).style font_style: :italic
          column(1).style overflow: :shrink_to_fit, min_font_size: 6
        end
      end

      def labeled_email(person, options = {})
        value = person.email
        return if value.blank?

        label = Person.human_attribute_name(:email)
        labeled_value(label, value, {cell_style: {height: 12}}.merge(options))
      end

      def labeled_phone_number(person, phone_label, options = {})
        value = @context.phone_number(person, phone_label)
        return if value.blank?

        label = I18n.t("events.fields_pbs.phone_#{phone_label.downcase}")
        labeled_value(label, value, options)
      end

      def labeled_person(person, details = true)
        labeled_value(Person.human_attribute_name(:name), person)
        labeled_value(Person.human_attribute_name(:address), person.address)
        labeled_value(Person.human_attribute_name(:town), [person.zip_code,
          person.town].compact.join(" "))
        labeled_email(person)
        labeled_phone_number(person, "Privat")
        labeled_phone_number(person, "Mobil")
        return unless details

        birthday = person.birthday.presence && I18n.l(person.birthday)
        labeled_value(Person.human_attribute_name(:birthday), birthday)
      end

      def title(title)
        move_down 18
        text translate(title), style: :bold, size: 12
        move_down 3
      end
    end
  end
end
