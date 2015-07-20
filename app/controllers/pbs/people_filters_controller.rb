# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::PeopleFiltersController
  extend ActiveSupport::Concern

  included do
    alias_method_chain :people_list_path, :education
  end

  def people_list_path_with_education
    if params[:education]
      :educations_path
    else
      people_list_path_without_education
    end
  end

end
