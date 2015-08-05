# encoding: utf-8

#  Copyright (c) 2014, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::PersonSerializer
  extend ActiveSupport::Concern

  included do
    extension(:details) do |_|
      map_properties :pbs_number, :salutation_value, :correspondence_language,
                     :grade_of_school, :brother_and_sisters, :entry_date, :leaving_date
    end
  end

end
