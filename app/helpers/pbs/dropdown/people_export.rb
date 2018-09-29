# encoding: utf-8

#  Copyright (c) 2012-2017, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs
  module Dropdown
    module PeopleExport
      extend ActiveSupport::Concern

      included do
        alias_method_chain :tabular_links, :detail
      end

      def tabular_links_with_detail(format)
        tabular_links_without_detail(format)

        path = params.merge(format: format)
        item = @items.find { |i| i.label == translate(format) }
        item.sub_items << ::Dropdown::Item.new(translate(:household_details),
          path.merge(household_details: true))
      end

    end
  end
end
