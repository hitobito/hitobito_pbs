#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Events::Filter::CourseList
  private

  def base_scope
    if params[:list_all_courses] == true
      Event::Course.all
    else
      Event::Course.in_hierarchy(user)
    end
  end
end
