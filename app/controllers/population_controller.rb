# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Displays a list of all people in an Abteilung that are counted.
class PopulationController < ApplicationController

  before_action :authorize

  decorates :groups, :people, :group


  def index
    @groups = load_groups

    @member_counter = MemberCounter.new(Time.zone.now.year, group)
    @total = @member_counter.count
    @members_per_birthyear = @member_counter.members_per_birthyear

    if group.is_a?(Group::Abteilung)
      @people_by_group = load_people_by_group
      @people_data_complete = people_data_complete?
    end
  end

  private

  def group
    @group ||= Group.find(params[:id])
  end

  def load_groups
    group.self_and_descendants.without_deleted.order_by_type(group)
  end

  def load_people_by_group
    @groups.each_with_object({}) do |group, hash|
      list = PersonDecorator.decorate_collection(load_people(group))
      hash[group] = list if list.present?
    end
  end

  def people_data_complete?
    @people_by_group.values.flatten.all? do |p|
      p.gender.present?
    end
  end

  def load_people(group)
    @member_counter.members.
      where(roles: { group_id: group }).
      includes(:groups).
      preload_groups.
      order_by_role.
      order_by_name
  end

  def authorize
    authorize!(:show_population, group)
  end

end
