# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Fabricator(:pbs_course, from: :course) do
  kind { Event::Kind.where(short_name: 'LPK').first }
end

Fabricator(:pbs_camp, from: :event, class_name: :'Event::Camp') do
  groups { [Group.all_types.detect { |t| t.event_types.include?(Event) }.first] }
end

Fabricator(:pbs_participation, from: :event_participation) do
  j_s_data_sharing_accepted_at { Time.zone.now }
end
