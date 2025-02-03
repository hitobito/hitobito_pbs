#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Event::Camp.role_types.collect { |t| t.name.to_sym }.each do |t|
  Fabricator(t, from: :event_role, class_name: t)
end
