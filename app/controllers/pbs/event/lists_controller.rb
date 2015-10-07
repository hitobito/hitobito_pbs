# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

module Pbs::Event::ListsController
  extend ActiveSupport::Concern

  included do
    skip_authorize_resource only: [:all_camps, :kantonalverband_camps,
                                   :camps_in_canton, :camps_abroad]
  end

  # List all camps everywhere coming up.
  def all_camps
    authorize!(:list_all, Event::Camp)

    @camps = grouped(all_upcoming_camps)
  end

  # List camps organized by the given Kantonalverband.
  def kantonalverband_camps
    authorize!(:list_cantonal, Event::Camp)

    @group = Group::Kantonalverband.find(params[:group_id])
    @camps = grouped(all_kantonalverband_camps)
  end

  # List camps taking place in the given canton.
  def camps_in_canton
    authorize!(:list_cantonal, Event::Camp)

    @camps = grouped(all_camps_in_canton)
  end

  # List camps taking place abroad.
  def camps_abroad
    authorize!(:list_abroad, Event::Camp)


    @camps = grouped(all_camps_abroad)
  end

  private

  def all_upcoming_camps
    in_next_three_weeks(base_camp_query('canceled').upcoming)
  end

  def all_kantonalverband_camps
    base_camp_query.
      joins(:groups).
      where('groups.lft >= ? AND groups.rgt <= ?', @group.lft, @group.rgt).
      in_year(year)
  end

  def all_camps_in_canton
    in_next_three_weeks(base_camp_query.
      where(canton: params[:canton]).
      upcoming)
  end

  def all_camps_abroad
    base_camp_query.
      where(canton: Event::Camp::ABROAD_CANTON).
      in_year(year)
  end

  def base_camp_query(excluded_states = %w(created canceled))
    Event::Camp.
      where(camp_submitted: true).
      where.not(state: excluded_states).
      includes(:groups).
      list
  end

  def in_next_three_weeks(scope)
    timespan = Time.zone.now.midnight + 3.weeks
    scope.where('event_dates.start_at <= ? OR event_dates.finish_at <= ?', timespan, timespan)
  end

end
