# encoding: utf-8

#  Copyright (c) 2021, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Pbs::PeopleSerializer
  extend ActiveSupport::Concern

  included do
    extension(:public) do |_|
      details = h.can?(:show_details, item)
      if details
        map_properties :gender, :birthday, :pbs_number, :entry_date, :leaving_date,
                       :primary_group_id
      end
    end
  end

end
