# encoding: utf-8

#  Copyright (c) 2012-2014, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

# Displays a list of all people in an Abteilung that are counted.
class PopulationController < ApplicationController

  before_filter :authorize

  decorates :groups, :people, :group


  def index
    @groups = load_groups
    @people_by_group = load_people_by_group
    @people_data_complete = people_data_complete?
    @total = MemberCounter.new(Time.zone.now.year, abteilung).count
  end

  private

  def abteilung
    @group ||= Group::Abteilung.find(params[:id])
  end

  def load_groups
    abteilung.self_and_descendants.without_deleted.order_by_type(abteilung)
  end

  def load_people_by_group
    @groups.each_with_object({}) do |group, hash|
      list = PersonDecorator.decorate(load_people(group))
      hash[group] = list if list.present?
    end
  end

  def people_data_complete?
    @people_by_group.values.flatten.all? do |p|
      p.gender.present?
    end
  end

  def load_people(group)
    Person.joins(:roles).
           where(roles: { group_id: group,
                          type: MemberCounter::ROLE_MAPPING.values.flatten.collect(&:sti_name),
                          deleted_at: nil }).
           preload_groups.
           uniq.
           order_by_role.
           order_by_name
  end

  def authorize
    authorize!(:show_population, abteilung)
  end

end
