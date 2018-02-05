# frozen_string_literal: true

#  Copyright (c) 2017, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs
  module FilterNavigation
    module Events
      extend ActiveSupport::Concern

      included do
        alias_method_chain :init_items, :canton
      end

      def init_items_with_canton
        init_items_without_canton

        if canton? && camps?
          filter_item('canton')
        end
      end

      def canton?
        @group.is_a?(::Group::Kantonalverband)
      end

      def camps?
        @template.params[:type] == ::Event::Camp.sti_name
      end

    end
  end
end
