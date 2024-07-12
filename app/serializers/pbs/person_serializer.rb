#  Copyright (c) 2014, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::PersonSerializer
  extend ActiveSupport::Concern

  included do
    extension(:details) do |_|
      map_properties :pbs_number, :salutation_value, :language,
        :prefers_digital_correspondence, :grade_of_school, :entry_date, :leaving_date

      # correspondence_language is deprecated and could be removed in the future
      property :correspondence_language, item.language

      if context[:group].present?
        property :has_siblings_in_layer, item.siblings_in_context(context[:group]).any?
      end
    end
  end
end
