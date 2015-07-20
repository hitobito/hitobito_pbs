# encoding: utf-8

#  Copyright (c) 2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::FilterNavigation::People
  extend ActiveSupport::Concern

  included do
    alias_method_chain :path, :education
    alias_method_chain :new_group_people_filter_path, :education
    alias_method_chain :delete_group_people_filter_path, :education
  end

  private

  def path_with_education(options = {})
    if education?
      template.educations_path(group, options)
    else
      path_without_education(options)
    end
  end

  def new_group_people_filter_path_with_education
    if education?
      template.new_group_people_filter_path(
        group.id,
        education: true,
        people_filter: { role_type_ids: role_type_ids })
    else
      new_group_people_filter_path_without_education
    end
  end

  def delete_group_people_filter_path_with_education(filter)
    if education?
      template.group_people_filter_path(group, filter, education: true)
    else
      delete_group_people_filter_path_without_education
    end
  end

  def education?
    template.controller_name == 'educations'
  end

end
