# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Lists grouped Membercounts per Census year.
#
# Old census subgroups contain only groups with existing member counts, to keep
# consistency even when groups have been merged, moved or deleted.
#
# Current census subgroups contain descendants of group without deleted subgroups
# at request time.
#
class CensusEvaluation::BaseController < ApplicationController

  include YearBasedPaging

  class_attribute :sub_group_type

  before_filter :authorize

  decorates :group, :sub_groups

  helper_method :current_census_year?

  def index
    current_census

    @census = Census.where(year: year).first
    @sub_groups = sub_groups
    @group_counts = counts_by_sub_group
    @total = group.census_total(year)
  end

  private

  def sub_groups
    if sub_group_type
      scope = locked? ? sub_groups_with_counts : current_census_sub_groups
      scope.order(:name)
    end
  end

  def locked?
    current_census && year < current_census.year
  end

  def sub_groups_with_counts
    Group.where(id: group.member_counts.where(year: year).
                                        select(sub_group_id_col).
                                        uniq)
  end

  def current_census_sub_groups
    sub_group_ids = current_sub_groups.pluck(:id)
    sub_group_ids -= sub_group_ids_with_other_group_count(sub_group_ids) unless group.class == Group::Bund
    sub_group_ids += sub_groups_with_counts.pluck(:id)
    Group.where(id: sub_group_ids.uniq)
  end

  def current_sub_groups
    group.descendants.where(type: sub_group_type.sti_name).without_deleted
  end

  def sub_group_ids_with_other_group_count(sub_group_ids)
    MemberCount.where(sub_group_id_col => sub_group_ids,
                      :year => year).
                where("#{group_id_col} <> ?", group.id).
                pluck(sub_group_id_col)
  end

  def sub_group_id_col
    "#{sub_group_type.model_name.element}_id"
  end

  def group_id_col
    "#{group.class.model_name.element}_id"
  end

  def counts_by_sub_group
    if sub_group_type
      sub_group_field = :"#{sub_group_type.model_name.element}_id"
      group.census_groups(year).inject({}) do |hash, count|
        hash[count.send(sub_group_field)] = count
        hash
      end
    end
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def current_census
    @current_census ||= Census.current
  end

  def current_census_year?
    current_census && year == current_census.year
  end

  def default_year
    @default_year ||= current_census.try(:year) || current_year
  end

  def current_year
    @current_year ||= Date.today.year
  end

  def year_range
    @year_range ||= (year - 3)..(year + 1)
  end

  def authorize
    authorize!(:evaluate_census, group)
  end
end
