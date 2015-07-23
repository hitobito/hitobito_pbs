# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class Group::EducationsController < ApplicationController

  helper_method :group
  decorates :group, :people

  def index
    authorize!(:education, group)
    @people = education_entries.page(params[:page])
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def education_entries
    filter_entries.
      includes(qualifications: [qualification_kind: :translations],
               event_participations: [event: :groups])
  end

  def filter_entries
    filter = Person::ListFilter.new(group, current_user, params[:kind], params[:role_type_ids])
    entries = filter.filter_entries.order_by_name
    @all_count = filter.all_count if html_request?
    entries
  end

end

