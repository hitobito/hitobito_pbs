# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Pbs::EventLinkSerializer < ::ApplicationSerializer

  schema do
    json_api_properties

    map_properties :id
    property :name, item.to_s
    property :href, h.group_event_url(item.groups.first, item, format: :json)
  end
end

