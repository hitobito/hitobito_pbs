# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Pbs::EventLinkSerializer < ::ApplicationSerializer
  extend ActiveSupport::Concern

  schema do
    json_api_properties

    map_properties :id
    property :href, h.event_url(item.id, format: :json)
  end
end

