#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs
  module ContactAttrs
    module ControlBuilder
      extend ActiveSupport::Concern

      included do
        alias_method_chain :initialize, :required_contact_attrs
        alias_method_chain :radio_buttons, :supercamp_flag
        alias_method_chain :assoc_checkbox, :supercamp_flag
      end

      def initialize_with_required_contact_attrs(form, event)
        initialize_without_required_contact_attrs(form, event)
        return if @event.persisted? || @event.event.type != "Event::Camp"

        @event.event.required_contact_attrs += %w[address zip_code town country gender birthday
          nationality_j_s language]
      end

      def radio_buttons_with_supercamp_flag(*args)
        radio_buttons_without_supercamp_flag(*args) +
          pass_on_to_supercamp_checkbox(args[0])
      end

      def assoc_checkbox_with_supercamp_flag(*args)
        assoc_checkbox_without_supercamp_flag(*args) +
          pass_on_to_supercamp_checkbox(args[0])
      end

      def pass_on_to_supercamp_checkbox(attr)
        return "" unless @event.event.parent_id

        f.label(supercamp_label(attr), class: "checkbox inline") do
          options = {checked: attr_passed_on_to_supercamp?(attr)}
          f.check_box(supercamp_label(attr), options) + option_label(:pass_on_to_supercamp)
        end
      end

      def supercamp_label(attr)
        "contact_attrs_passed_on_to_supercamp[#{attr}]"
      end

      def attr_passed_on_to_supercamp?(attr)
        event.contact_attrs_passed_on_to_supercamp.include?(attr.to_s)
      end
    end
  end
end
