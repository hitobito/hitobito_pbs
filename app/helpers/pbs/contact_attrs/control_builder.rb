# encoding: utf-8

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
      end

      def initialize_with_required_contact_attrs(form, event)
        initialize_without_required_contact_attrs(form, event)
        return if @event.persisted? || @event.event.type != 'Event::Camp'

        @event.event.required_contact_attrs += %w(address zip_code town country gender birthday
                                                  nationality_j_s ahv_number
                                                  correspondence_language)
      end
    end
  end
end
