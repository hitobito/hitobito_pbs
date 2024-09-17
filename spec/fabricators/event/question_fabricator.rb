# encoding: utf-8

#  Copyright (c) 2019, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

Fabricator(:question, class_name: 'Event::Question') do
  event { Fabricate(:bund_camp) }
  question { 'Ja oder nein?' }
  choices { 'Ja,Nein' }
  admin { false }
  disclosure { "optional" }
end
