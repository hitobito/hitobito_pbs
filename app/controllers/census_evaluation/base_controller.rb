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

  before_action :authorize

  decorates :group, :sub_groups

  def index
    @sub_groups = evaluation.sub_groups
    @group_counts = evaluation.counts_by_sub_group
    @total = evaluation.total
  end

  private

  def evaluation
    @evaluation ||= CensusEvaluation.new(year, group, sub_group_type)
  end

  def group
    @group ||= Group.find(params[:id])
  end

  def default_year
    @default_year ||= Census.current.try(:year) || current_year
  end

  def current_year
    @current_year ||= Time.zone.today.year
  end

  def year_range
    @year_range ||= (year - 3)..(year + 1)
  end

  def authorize
    authorize!(:evaluate_census, group)
  end
end
